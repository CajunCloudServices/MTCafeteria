'use strict';

const http = require('node:http');
const path = require('node:path');
const test = require('node:test');
const assert = require('node:assert/strict');

const backendSrcFragment = `${path.sep}backend${path.sep}src${path.sep}`;

function clearBackendModules() {
  for (const key of Object.keys(require.cache)) {
    if (key.includes(backendSrcFragment)) {
      delete require.cache[key];
    }
  }
}

async function withFreshApp(envOverrides, callback) {
  const trackedKeys = new Set([
    'NODE_ENV',
    'USE_MOCK_DATA',
    'JWT_SECRET',
    'DATABASE_URL',
    'CORS_ORIGINS',
    'TASK_EDITOR_PASSWORD',
    'POSTGRES_PASSWORD',
    ...Object.keys(envOverrides),
  ]);
  const previous = new Map();
  for (const key of trackedKeys) {
    previous.set(key, process.env[key]);
  }

  for (const [key, value] of Object.entries(envOverrides)) {
    if (value == null) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }

  clearBackendModules();

  try {
    const app = require('../src/server');
    await callback(app);
  } finally {
    clearBackendModules();
    for (const [key, value] of previous.entries()) {
      if (value == null) {
        delete process.env[key];
      } else {
        process.env[key] = value;
      }
    }
  }
}

function startServer(app) {
  return new Promise((resolve) => {
    const server = http.createServer(app);
    server.listen(0, () => {
      const { port } = server.address();
      resolve({ server, port });
    });
  });
}

async function request(port, method, requestPath, body, extraHeaders = {}) {
  const data = body ? JSON.stringify(body) : null;
  const options = {
    hostname: '127.0.0.1',
    port,
    path: requestPath,
    method,
    headers: {
      Accept: 'application/json',
      ...(data
        ? { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(data) }
        : {}),
      ...extraHeaders,
    },
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        const raw = Buffer.concat(chunks).toString('utf8');
        let parsed = null;
        if (raw.length > 0) {
          try {
            parsed = JSON.parse(raw);
          } catch (_) {
            parsed = raw;
          }
        }
        resolve({ status: res.statusCode, body: parsed, headers: res.headers });
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

async function login(port, email, password) {
  const response = await request(port, 'POST', '/api/auth/login', { email, password });
  assert.equal(response.status, 200, `Expected login to succeed for ${email}`);
  assert.equal(typeof response.body.token, 'string');
  return response.body.token;
}

function authHeaders(token, extraHeaders = {}) {
  return {
    Authorization: `Bearer ${token}`,
    ...extraHeaders,
  };
}

test('points assignment lifecycle works across submit, approval, inbox, and acceptance', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
      TASK_EDITOR_PASSWORD: 'editor-secret',
    },
    async (app) => {
      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const supervisorToken = await login(port, 'supervisor@mtc.local', 'password123');
      const managerToken = await login(port, 'manager@mtc.local', 'password123');
      const employeeToken = await login(port, 'employee2@mtc.local', 'password123');

      const assignable = await request(
        port,
        'GET',
        '/api/points/assignable-users',
        null,
        authHeaders(supervisorToken)
      );
      assert.equal(assignable.status, 200);
      assert.ok(assignable.body.some((user) => user.email === 'employee2@mtc.local'));
      assert.ok(assignable.body.every((user) => user.email !== 'supervisor@mtc.local'));

      const create = await request(
        port,
        'POST',
        '/api/points/assignments',
        {
          assignedToUserId: 5,
          pointsDelta: 2,
          assignmentDate: '2026-04-24',
          reason: 'Dress Code',
          assignmentDescription: 'Apron was missing at shift start.',
        },
        authHeaders(supervisorToken)
      );
      assert.equal(create.status, 201);
      assert.equal(create.body.status, 'Pending');
      assert.equal(create.body.requiresManagerApproval, true);
      assert.equal(create.body.assignedToEmail, 'employee2@mtc.local');
      assert.equal(create.body.assignedByEmail, 'supervisor@mtc.local');
      assert.equal(create.body.pointsDelta, 2);

      const createdId = create.body.id;

      const inboxBeforeApproval = await request(
        port,
        'GET',
        '/api/points/assignments/inbox',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(inboxBeforeApproval.status, 200);
      assert.ok(inboxBeforeApproval.body.every((assignment) => assignment.id !== createdId));

      const sent = await request(
        port,
        'GET',
        '/api/points/assignments/sent',
        null,
        authHeaders(supervisorToken)
      );
      assert.equal(sent.status, 200);
      assert.ok(sent.body.some((assignment) => assignment.id === createdId));

      const approvalQueue = await request(
        port,
        'GET',
        '/api/points/assignments/approval-queue',
        null,
        authHeaders(managerToken)
      );
      assert.equal(approvalQueue.status, 200);
      assert.ok(approvalQueue.body.some((assignment) => assignment.id === createdId));

      const approve = await request(
        port,
        'POST',
        `/api/points/assignments/${createdId}/approve`,
        {},
        authHeaders(managerToken)
      );
      assert.equal(approve.status, 200);
      assert.equal(approve.body.managerApprovedByEmail, 'manager@mtc.local');
      assert.ok(approve.body.managerApprovedAt);

      const inboxAfterApproval = await request(
        port,
        'GET',
        '/api/points/assignments/inbox',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(inboxAfterApproval.status, 200);
      assert.ok(inboxAfterApproval.body.some((assignment) => assignment.id === createdId));

      const accept = await request(
        port,
        'POST',
        `/api/points/assignments/${createdId}/accept`,
        { initials: 'ej' },
        authHeaders(employeeToken)
      );
      assert.equal(accept.status, 200);
      assert.equal(accept.body.assignment.status, 'Accepted');
      assert.equal(accept.body.assignment.employeeInitials, 'EJ');
      assert.equal(accept.body.updatedPoints, 11);

      const inboxAfterAcceptance = await request(
        port,
        'GET',
        '/api/points/assignments/inbox',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(inboxAfterAcceptance.status, 200);
      assert.ok(inboxAfterAcceptance.body.every((assignment) => assignment.id !== createdId));
    }
  );
});

test('student manager assignments bypass approval and show up in the employee inbox immediately', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
      TASK_EDITOR_PASSWORD: 'editor-secret',
    },
    async (app) => {
      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const managerToken = await login(port, 'manager@mtc.local', 'password123');
      const employeeToken = await login(port, 'employee3@mtc.local', 'password123');

      const create = await request(
        port,
        'POST',
        '/api/points/assignments',
        {
          assignedToUserId: 6,
          pointsDelta: 3,
          assignmentDate: '2026-04-24',
          reason: 'No Show',
          assignmentDescription: 'Missed assigned task rotation.',
        },
        authHeaders(managerToken)
      );
      assert.equal(create.status, 201);
      assert.equal(create.body.requiresManagerApproval, false);
      assert.equal(create.body.managerApprovedByEmail, 'manager@mtc.local');
      assert.ok(create.body.managerApprovedAt);

      const createdId = create.body.id;

      const approvalQueue = await request(
        port,
        'GET',
        '/api/points/assignments/approval-queue',
        null,
        authHeaders(managerToken)
      );
      assert.equal(approvalQueue.status, 200);
      assert.ok(approvalQueue.body.every((assignment) => assignment.id !== createdId));

      const inbox = await request(
        port,
        'GET',
        '/api/points/assignments/inbox',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(inbox.status, 200);
      assert.ok(inbox.body.some((assignment) => assignment.id === createdId));
    }
  );
});

test('employees cannot access leadership-only points endpoints', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
      TASK_EDITOR_PASSWORD: 'editor-secret',
    },
    async (app) => {
      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const employeeToken = await login(port, 'employee@mtc.local', 'password123');

      const assignable = await request(
        port,
        'GET',
        '/api/points/assignable-users',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(assignable.status, 403);

      const create = await request(
        port,
        'POST',
        '/api/points/assignments',
        {
          assignedToUserId: 5,
          pointsDelta: 1,
          assignmentDate: '2026-04-24',
          reason: 'Late < 30 minutes',
          assignmentDescription: 'Test assignment',
        },
        authHeaders(employeeToken)
      );
      assert.equal(create.status, 403);

      const sent = await request(
        port,
        'GET',
        '/api/points/assignments/sent',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(sent.status, 403);

      const approvalQueue = await request(
        port,
        'GET',
        '/api/points/assignments/approval-queue',
        null,
        authHeaders(employeeToken)
      );
      assert.equal(approvalQueue.status, 403);
    }
  );
});
