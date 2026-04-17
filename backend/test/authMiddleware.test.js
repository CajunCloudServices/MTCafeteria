'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const jwt = require('jsonwebtoken');
const path = require('node:path');

const backendSrcFragment = `${path.sep}backend${path.sep}src${path.sep}`;

function clearBackendModules() {
  for (const key of Object.keys(require.cache)) {
    if (key.includes(backendSrcFragment)) {
      delete require.cache[key];
    }
  }
}

function withEnv(overrides, callback) {
  const trackedKeys = new Set([
    'NODE_ENV',
    'USE_MOCK_DATA',
    'JWT_SECRET',
    ...Object.keys(overrides),
  ]);
  const previous = new Map();
  for (const key of trackedKeys) {
    previous.set(key, process.env[key]);
  }

  for (const [key, value] of Object.entries(overrides)) {
    if (value == null) {
      delete process.env[key];
    } else {
      process.env[key] = value;
    }
  }

  clearBackendModules();

  return Promise.resolve()
    .then(callback)
    .finally(() => {
      clearBackendModules();
      for (const [key, value] of previous.entries()) {
        if (value == null) {
          delete process.env[key];
        } else {
          process.env[key] = value;
        }
      }
    });
}

function createResponseRecorder() {
  return {
    statusCode: 200,
    body: null,
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
  };
}

test('requireAuth rejects requests without a bearer token', async () => {
  await withEnv(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
    },
    async () => {
      const { requireAuth } = require('../src/middleware/authMiddleware');
      const req = { headers: {} };
      const res = createResponseRecorder();
      let calledNext = false;

      requireAuth(req, res, () => {
        calledNext = true;
      });

      assert.equal(calledNext, false);
      assert.equal(res.statusCode, 401);
      assert.equal(res.body.message, 'Authentication required.');
    }
  );
});

test('requireAuth rejects invalid bearer tokens', async () => {
  await withEnv(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
    },
    async () => {
      const { requireAuth } = require('../src/middleware/authMiddleware');
      const req = { headers: { authorization: 'Bearer not-a-real-token' } };
      const res = createResponseRecorder();
      let calledNext = false;

      requireAuth(req, res, () => {
        calledNext = true;
      });

      assert.equal(calledNext, false);
      assert.equal(res.statusCode, 401);
      assert.equal(res.body.message, 'Invalid or expired token.');
    }
  );
});

test('requireAuth accepts valid bearer tokens and attaches req.user', async () => {
  await withEnv(
    {
      NODE_ENV: 'test',
      USE_MOCK_DATA: 'true',
      JWT_SECRET: 'test-secret',
    },
    async () => {
      const { requireAuth } = require('../src/middleware/authMiddleware');
      const token = jwt.sign(
        { sub: 4, email: 'manager@mtc.local', role: 'Student Manager' },
        'test-secret'
      );
      const req = { headers: { authorization: `Bearer ${token}` } };
      const res = createResponseRecorder();

      await new Promise((resolve) => {
        requireAuth(req, res, resolve);
      });

      assert.equal(req.user.sub, 4);
      assert.equal(req.user.email, 'manager@mtc.local');
      assert.equal(req.user.role, 'Student Manager');
      assert.equal(res.body, null);
    }
  );
});
