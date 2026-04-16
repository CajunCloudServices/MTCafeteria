'use strict';

// Smoke tests for the Express app. These run against mock data so they do not
// require a Postgres connection and are safe to execute in CI or on a laptop.

process.env.USE_MOCK_DATA = 'true';
process.env.JWT_SECRET = process.env.JWT_SECRET || 'test-secret';
process.env.NODE_ENV = 'test';

const http = require('node:http');
const test = require('node:test');
const assert = require('node:assert/strict');

const app = require('../src/server');

function startServer() {
  return new Promise((resolve) => {
    const server = http.createServer(app);
    server.listen(0, () => {
      const { port } = server.address();
      resolve({ server, port });
    });
  });
}

async function request(port, method, path, body, extraHeaders = {}) {
  const data = body ? JSON.stringify(body) : null;
  const options = {
    hostname: '127.0.0.1',
    port,
    path,
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
        resolve({ status: res.statusCode, body: parsed });
      });
    });
    req.on('error', reject);
    if (data) req.write(data);
    req.end();
  });
}

test('smoke: mock mode surfaces expected endpoints', async (t) => {
  const { server, port } = await startServer();
  t.after(() => new Promise((resolve) => server.close(resolve)));

  await t.test('GET /health returns ok + mock mode', async () => {
    const res = await request(port, 'GET', '/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.status, 'ok');
    assert.equal(res.body.mode, 'mock');
  });

  await t.test('GET /api/health mirrors /health', async () => {
    const res = await request(port, 'GET', '/api/health');
    assert.equal(res.status, 200);
    assert.equal(res.body.status, 'ok');
  });

  await t.test('GET /api/content/landing-items returns the baseline cards', async () => {
    const res = await request(port, 'GET', '/api/content/landing-items');
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body));
    assert.ok(res.body.length >= 3);
    for (const item of res.body) {
      for (const field of ['id', 'type', 'title', 'content', 'startDate', 'endDate']) {
        assert.ok(item[field] != null, `Expected landing item to include ${field}`);
      }
    }
  });

  await t.test('POST /api/content/landing-items validates required fields', async () => {
    const res = await request(port, 'POST', '/api/content/landing-items', { title: 'Just a title' });
    assert.equal(res.status, 400);
    assert.ok(Array.isArray(res.body.missingFields));
    assert.ok(res.body.missingFields.includes('type'));
    assert.ok(res.body.missingFields.includes('content'));
  });

  await t.test('GET /api/unknown returns structured 404', async () => {
    const res = await request(port, 'GET', '/api/unknown');
    assert.equal(res.status, 404);
    assert.equal(res.body.message, 'Not found.');
  });
});

test('task-admin: password gate + CRUD over jobs and tasks', async (t) => {
  const { server, port } = await startServer();
  t.after(() => new Promise((resolve) => server.close(resolve)));

  const pwHeaders = { 'X-Task-Editor-Password': 'yoboss' };

  await t.test('requires password header', async () => {
    const res = await request(port, 'GET', '/api/task-admin/board');
    assert.equal(res.status, 401);
    assert.match(res.body.message, /password required/i);
  });

  await t.test('rejects wrong password', async () => {
    const res = await request(port, 'GET', '/api/task-admin/board', null, {
      'X-Task-Editor-Password': 'wrong',
    });
    assert.equal(res.status, 403);
  });

  await t.test('lists board with shifts, jobs, and phases', async () => {
    const res = await request(port, 'GET', '/api/task-admin/board', null, pwHeaders);
    assert.equal(res.status, 200);
    assert.ok(Array.isArray(res.body.shifts));
    assert.ok(res.body.shifts.length >= 3);
    assert.ok(Array.isArray(res.body.jobs));
    assert.ok(res.body.jobs.length > 0);
    assert.deepEqual(res.body.phases, ['Setup', 'During Shift', 'Cleanup']);
    const firstJob = res.body.jobs[0];
    for (const phase of ['Setup', 'During Shift', 'Cleanup']) {
      assert.ok(Array.isArray(firstJob.tasks[phase]));
    }
  });

  await t.test('creates, updates, and deletes a job + its tasks', async () => {
    const shiftsRes = await request(port, 'GET', '/api/task-admin/board', null, pwHeaders);
    const shiftId = shiftsRes.body.shifts[0].id;

    const create = await request(port, 'POST', '/api/task-admin/jobs',
      { name: 'Smoke Test Station', shiftId }, pwHeaders);
    assert.equal(create.status, 201);
    assert.equal(create.body.name, 'Smoke Test Station');
    const jobId = create.body.id;

    const rename = await request(port, 'PATCH', `/api/task-admin/jobs/${jobId}`,
      { name: 'Smoke Test Station Renamed' }, pwHeaders);
    assert.equal(rename.status, 200);
    assert.equal(rename.body.name, 'Smoke Test Station Renamed');

    const addTask = await request(port, 'POST', `/api/task-admin/jobs/${jobId}/tasks`,
      { description: 'Check the smoke detector', phase: 'Setup' }, pwHeaders);
    assert.equal(addTask.status, 201);
    assert.equal(addTask.body.phase, 'Setup');
    assert.equal(addTask.body.description, 'Check the smoke detector');
    const taskId = addTask.body.id;

    const editTask = await request(port, 'PATCH', `/api/task-admin/tasks/${taskId}`,
      { description: 'Confirm smoke detector is clear', phase: 'Cleanup' }, pwHeaders);
    assert.equal(editTask.status, 200);
    assert.equal(editTask.body.description, 'Confirm smoke detector is clear');
    assert.equal(editTask.body.phase, 'Cleanup');

    const deleteTask = await request(port, 'DELETE', `/api/task-admin/tasks/${taskId}`, null, pwHeaders);
    assert.equal(deleteTask.status, 204);

    const deleteJob = await request(port, 'DELETE', `/api/task-admin/jobs/${jobId}`, null, pwHeaders);
    assert.equal(deleteJob.status, 204);
  });

  await t.test('rejects invalid input with 400', async () => {
    const res = await request(port, 'POST', '/api/task-admin/jobs', { name: '', shiftId: 0 }, pwHeaders);
    assert.equal(res.status, 400);
  });

  await t.test('returns 404 for missing job', async () => {
    const res = await request(port, 'PATCH', '/api/task-admin/jobs/999999',
      { name: 'Nope' }, pwHeaders);
    assert.equal(res.status, 404);
  });
});
