'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

function loadRequireAuth() {
  const modulePath = require.resolve('../src/middleware/authMiddleware');
  delete require.cache[modulePath];
  return require('../src/middleware/authMiddleware').requireAuth;
}

test('requireAuth defaults shared session to seeded manager user id', async () => {
  const previousUserId = process.env.SHARED_SESSION_USER_ID;
  const previousEmail = process.env.SHARED_SESSION_EMAIL;
  const previousRole = process.env.SHARED_SESSION_ROLE;

  delete process.env.SHARED_SESSION_USER_ID;
  delete process.env.SHARED_SESSION_EMAIL;
  delete process.env.SHARED_SESSION_ROLE;

  const requireAuth = loadRequireAuth();
  const req = { headers: {} };

  await new Promise((resolve) => requireAuth(req, {}, resolve));

  assert.equal(req.user.sub, 4);
  assert.equal(req.user.role, 'Student Manager');

  if (previousUserId == null) {
    delete process.env.SHARED_SESSION_USER_ID;
  } else {
    process.env.SHARED_SESSION_USER_ID = previousUserId;
  }
  if (previousEmail == null) {
    delete process.env.SHARED_SESSION_EMAIL;
  } else {
    process.env.SHARED_SESSION_EMAIL = previousEmail;
  }
  if (previousRole == null) {
    delete process.env.SHARED_SESSION_ROLE;
  } else {
    process.env.SHARED_SESSION_ROLE = previousRole;
  }
});
