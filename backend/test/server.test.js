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

async function request(port, method, path, body) {
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
