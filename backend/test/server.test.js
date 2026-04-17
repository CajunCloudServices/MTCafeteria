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

test('mock mode: health endpoints are public and landing items remain readable', async (t) => {
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

      await t.test('GET /livez reports liveness', async () => {
        const res = await request(port, 'GET', '/livez');
        assert.equal(res.status, 200);
        assert.equal(res.body.status, 'ok');
        assert.equal(res.body.mode, 'mock');
      });

      await t.test('GET /health reports dependency-aware mock readiness', async () => {
        const res = await request(port, 'GET', '/health');
        assert.equal(res.status, 200);
        assert.equal(res.body.status, 'ok');
        assert.equal(res.body.mode, 'mock');
        assert.equal(res.body.dependencies.database.status, 'ok');
        assert.equal(res.body.dependencies.database.type, 'mock');
      });

      await t.test('GET /api/health mirrors readiness payload', async () => {
        const res = await request(port, 'GET', '/api/health');
        assert.equal(res.status, 200);
        assert.equal(res.body.status, 'ok');
        assert.equal(res.body.dependencies.database.type, 'mock');
      });

      await t.test('GET /api/content/landing-items remains public', async () => {
        const res = await request(port, 'GET', '/api/content/landing-items');
        assert.equal(res.status, 200);
        assert.ok(Array.isArray(res.body));
        assert.ok(res.body.length >= 3);
      });
    }
  );
});

test('protected routes require real auth and role checks', async (t) => {
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

      await t.test('GET /api/task-board rejects missing auth', async () => {
        const res = await request(port, 'GET', '/api/task-board?meal=Breakfast');
        assert.equal(res.status, 401);
        assert.equal(res.body.message, 'Authentication required.');
      });

      await t.test('GET /api/task-board rejects invalid tokens', async () => {
        const res = await request(port, 'GET', '/api/task-board?meal=Breakfast', null, {
          Authorization: 'Bearer invalid-token',
        });
        assert.equal(res.status, 401);
        assert.equal(res.body.message, 'Invalid or expired token.');
      });

      await t.test('POST /api/content/landing-items rejects missing auth', async () => {
        const res = await request(port, 'POST', '/api/content/landing-items', {
          type: 'Reminder',
          title: 'Test',
          content: 'Body',
          startDate: '2026-01-01',
          endDate: '2026-01-31',
        });
        assert.equal(res.status, 401);
      });

      await t.test('GET /api/trainings rejects employee role after auth', async () => {
        const employeeToken = await login(port, 'employee@mtc.local', 'password123');
        const res = await request(port, 'GET', '/api/trainings', null, authHeaders(employeeToken));
        assert.equal(res.status, 403);
        assert.equal(res.body.message, 'Access denied for this role.');
      });

      await t.test('GET /api/trainings succeeds for a leadership role', async () => {
        const managerToken = await login(port, 'manager@mtc.local', 'password123');
        const res = await request(port, 'GET', '/api/trainings', null, authHeaders(managerToken));
        assert.equal(res.status, 200);
        assert.ok(Array.isArray(res.body.trainings));
      });
    }
  );
});

test('task-admin requires both JWT auth and the task-editor password', async (t) => {
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

      await t.test('rejects missing auth before checking password', async () => {
        const res = await request(port, 'GET', '/api/task-admin/board');
        assert.equal(res.status, 401);
        assert.equal(res.body.message, 'Authentication required.');
      });

      await t.test('rejects missing task-editor password after auth', async () => {
        const token = await login(port, 'manager@mtc.local', 'password123');
        const res = await request(port, 'GET', '/api/task-admin/board', null, authHeaders(token));
        assert.equal(res.status, 401);
        assert.match(res.body.message, /password required/i);
      });

      await t.test('rejects wrong task-editor password', async () => {
        const token = await login(port, 'manager@mtc.local', 'password123');
        const res = await request(
          port,
          'GET',
          '/api/task-admin/board',
          null,
          authHeaders(token, { 'X-Task-Editor-Password': 'wrong' })
        );
        assert.equal(res.status, 403);
      });

      await t.test('returns board when both auth factors are present', async () => {
        const token = await login(port, 'manager@mtc.local', 'password123');
        const res = await request(
          port,
          'GET',
          '/api/task-admin/board',
          null,
          authHeaders(token, { 'X-Task-Editor-Password': 'editor-secret' })
        );
        assert.equal(res.status, 200);
        assert.ok(Array.isArray(res.body.shifts));
        assert.ok(Array.isArray(res.body.jobs));
      });
    }
  );
});

test('task-board completion persists for authenticated employees', async (t) => {
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
      const headers = authHeaders(employeeToken);

      const breakfastBoard = await request(port, 'GET', '/api/task-board?meal=Breakfast', null, headers);
      assert.equal(breakfastBoard.status, 200);
      const beveragesJob = breakfastBoard.body.jobs.find((job) => job.name === 'Beverages');
      assert.ok(beveragesJob, 'Expected breakfast Beverages job to exist');

      const boardBefore = await request(
        port,
        'GET',
        `/api/task-board?meal=Breakfast&jobId=${beveragesJob.id}`,
        null,
        headers
      );
      assert.equal(boardBefore.status, 200);

      const targetTask = boardBefore.body.tasks.find(
        (task) => task.phase === 'Setup' && task.description === 'Turn on beverage machines'
      );
      assert.ok(targetTask, 'Expected breakfast beverages setup task to exist');
      assert.equal(targetTask.completed, false);

      const toggle = await request(
        port,
        'POST',
        `/api/task-board/tasks/${targetTask.taskId}/completion`,
        { completed: true },
        headers
      );
      assert.equal(toggle.status, 204);

      const boardAfter = await request(
        port,
        'GET',
        `/api/task-board?meal=Breakfast&jobId=${beveragesJob.id}`,
        null,
        headers
      );
      assert.equal(boardAfter.status, 200);

      const updatedTask = boardAfter.body.tasks.find((task) => task.taskId === targetTask.taskId);
      assert.ok(updatedTask);
      assert.equal(updatedTask.completed, true);
    }
  );
});

test('async route failures are converted into structured 500 responses', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
      TASK_EDITOR_PASSWORD: 'editor-secret',
    },
    async (app) => {
      const pointsService = require('../src/services/pointsService');
      const original = pointsService.listPendingAssignmentsForUser;
      pointsService.listPendingAssignmentsForUser = async () => {
        throw new Error('boom');
      };
      t.after(() => {
        pointsService.listPendingAssignmentsForUser = original;
      });

      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const employeeToken = await login(port, 'employee@mtc.local', 'password123');
      const res = await request(
        port,
        'GET',
        '/api/points/assignments/inbox',
        null,
        authHeaders(employeeToken)
      );

      assert.equal(res.status, 500);
      assert.equal(res.body.message, 'Internal server error.');
    }
  );
});

test('postgres readiness reports degraded when the database probe fails', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'false',
      JWT_SECRET: 'test-secret',
      DATABASE_URL: 'postgresql://postgres:secret@localhost:5432/mtc_cafeteria',
      CORS_ORIGINS: 'http://localhost:3000',
      TASK_EDITOR_PASSWORD: 'editor-secret',
    },
    async (app) => {
      const db = require('../src/db/pool');
      const originalQuery = db.pool.query;
      db.pool.query = async () => {
        throw new Error('connection refused');
      };
      t.after(() => {
        db.pool.query = originalQuery;
      });

      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const res = await request(port, 'GET', '/health');
      assert.equal(res.status, 503);
      assert.equal(res.body.status, 'degraded');
      assert.equal(res.body.mode, 'postgres');
      assert.equal(res.body.dependencies.database.status, 'unavailable');
      assert.equal(res.body.dependencies.database.type, 'postgres');
    }
  );
});

test('chatbot proxy reports disabled when no upstream is configured', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
      TASK_EDITOR_PASSWORD: 'editor-secret',
      CHATBOT_UPSTREAM_URL: null,
      CHATBOT_API_TOKEN: null,
    },
    async (app) => {
      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const res = await request(port, 'GET', '/api/chatbot/health');
      assert.equal(res.status, 503);
      assert.equal(res.body.configured, false);
      assert.equal(res.body.status, 'disabled');
    }
  );
});

test('chatbot proxy forwards health and chat requests', async (t) => {
  await withFreshApp(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
      TASK_EDITOR_PASSWORD: 'editor-secret',
      CHATBOT_UPSTREAM_URL: 'http://chatbot.example.test',
      CHATBOT_API_TOKEN: 'chatbot-token',
    },
    async (app) => {
      const chatbotService = require('../src/services/chatbotService');
      const originalHealth = chatbotService.checkChatbotHealth;
      const originalSend = chatbotService.sendChatMessage;

      chatbotService.checkChatbotHealth = async () => ({
        ok: true,
        configured: true,
        status: 'ok',
        upstreamStatus: 200,
        payload: { ok: true },
      });
      chatbotService.sendChatMessage = async ({ message, sessionId }) => ({
        reply: `Echo: ${message}`,
        sessionId: sessionId || 'generated-session',
      });

      t.after(() => {
        chatbotService.checkChatbotHealth = originalHealth;
        chatbotService.sendChatMessage = originalSend;
      });

      const { server, port } = await startServer(app);
      t.after(() => new Promise((resolve) => server.close(resolve)));

      const health = await request(port, 'GET', '/api/chatbot/health');
      assert.equal(health.status, 200);
      assert.equal(health.body.ok, true);
      assert.equal(health.body.status, 'ok');

      const chat = await request(port, 'POST', '/api/chatbot/chat', {
        message: 'Where are the drinks?',
        sessionId: 'test-session',
      });
      assert.equal(chat.status, 200);
      assert.equal(chat.body.reply, 'Echo: Where are the drinks?');
      assert.equal(chat.body.sessionId, 'test-session');
    }
  );
});
