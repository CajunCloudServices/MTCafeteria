'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
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
    'DATABASE_URL',
    'CORS_ORIGINS',
    'TASK_EDITOR_PASSWORD',
    'POSTGRES_PASSWORD',
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

test('production env validation rejects placeholder JWT secrets', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      USE_MOCK_DATA: 'false',
      JWT_SECRET: 'replace-with-strong-secret',
      DATABASE_URL: 'postgresql://postgres:secret@localhost:5432/mtc_cafeteria',
      CORS_ORIGINS: 'https://cafeteria.example.com',
      TASK_EDITOR_PASSWORD: 'editor-secret',
    },
    async () => {
      assert.throws(
        () => require('../src/config/env'),
        /JWT_SECRET must not use a placeholder or default value in production/
      );
    }
  );
});

test('production env validation requires TASK_EDITOR_PASSWORD', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      USE_MOCK_DATA: 'false',
      JWT_SECRET: 'super-secret',
      DATABASE_URL: 'postgresql://postgres:secret@localhost:5432/mtc_cafeteria',
      CORS_ORIGINS: 'https://cafeteria.example.com',
      TASK_EDITOR_PASSWORD: null,
    },
    async () => {
      assert.throws(
        () => require('../src/config/env'),
        /TASK_EDITOR_PASSWORD is required in production/
      );
    }
  );
});

test('production env validation rejects placeholder database configuration', async () => {
  await withEnv(
    {
      NODE_ENV: 'production',
      USE_MOCK_DATA: 'false',
      JWT_SECRET: 'super-secret',
      DATABASE_URL: 'postgresql://postgres:postgres@postgres:5432/mtc_cafeteria',
      CORS_ORIGINS: 'https://cafeteria.example.com',
      TASK_EDITOR_PASSWORD: 'editor-secret',
      POSTGRES_PASSWORD: 'postgres',
    },
    async () => {
      assert.throws(
        () => require('../src/config/env'),
        /DATABASE_URL must not use a placeholder or default value in production/
      );
    }
  );
});
