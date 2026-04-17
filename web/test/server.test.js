const assert = require('node:assert/strict');
const fs = require('node:fs');
const http = require('node:http');
const os = require('node:os');
const path = require('node:path');
const test = require('node:test');

const { createApp } = require('../server');

function createFlutterBuildFixture() {
  const buildDir = fs.mkdtempSync(path.join(os.tmpdir(), 'mtc-web-build-'));
  fs.mkdirSync(path.join(buildDir, 'assets'), { recursive: true });
  fs.writeFileSync(path.join(buildDir, 'index.html'), '<!doctype html><html><body>app</body></html>');
  fs.writeFileSync(path.join(buildDir, 'main.dart.js'), 'console.log("app");');
  fs.writeFileSync(path.join(buildDir, 'assets', 'logo.txt'), 'asset');
  return buildDir;
}

async function startServer(server) {
  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const address = server.address();
  return `http://127.0.0.1:${address.port}`;
}

async function createWebServer(options) {
  const server = http.createServer(createApp(options));
  const baseUrl = await startServer(server);
  return {
    baseUrl,
    async close() {
      await new Promise((resolve, reject) => server.close((error) => (error ? reject(error) : resolve())));
    },
  };
}

async function createApiStub({ healthStatus = 200, healthBody, apiHealthBody } = {}) {
  const body = healthBody || JSON.stringify({ status: 'ok' });
  const proxiedBody = apiHealthBody || JSON.stringify({ status: 'ok', source: 'api' });
  const server = http.createServer((req, res) => {
    if (req.url === '/health') {
      res.statusCode = healthStatus;
      res.setHeader('Content-Type', 'application/json');
      res.end(body);
      return;
    }
    if (req.url === '/api/health') {
      res.setHeader('Content-Type', 'application/json');
      res.end(proxiedBody);
      return;
    }
    res.statusCode = 404;
    res.end('not found');
  });

  const baseUrl = await startServer(server);
  return {
    baseUrl,
    async close() {
      await new Promise((resolve, reject) => server.close((error) => (error ? reject(error) : resolve())));
    },
  };
}

test('GET /health reports liveness even before the bundle exists', async () => {
  const web = await createWebServer({
    buildDir: path.join(os.tmpdir(), 'missing-build-dir'),
    apiUpstreamUrl: 'http://127.0.0.1:9',
  });

  try {
    const response = await fetch(`${web.baseUrl}/health`);
    assert.equal(response.status, 200);
    const json = await response.json();
    assert.equal(json.status, 'ok');
    assert.equal(json.buildPresent, false);
  } finally {
    await web.close();
  }
});

test('GET /readyz fails when the Flutter bundle is missing', async () => {
  const web = await createWebServer({
    buildDir: path.join(os.tmpdir(), 'missing-build-dir-readyz'),
    apiUpstreamUrl: 'http://127.0.0.1:9',
  });

  try {
    const response = await fetch(`${web.baseUrl}/readyz`);
    assert.equal(response.status, 503);
    const json = await response.json();
    assert.equal(json.build, 'missing');
  } finally {
    await web.close();
  }
});

test('GET /readyz fails when the API upstream is unavailable', async () => {
  const buildDir = createFlutterBuildFixture();
  const web = await createWebServer({
    buildDir,
    apiUpstreamUrl: 'http://127.0.0.1:9',
    readinessTimeoutMs: 200,
  });

  try {
    const response = await fetch(`${web.baseUrl}/readyz`);
    assert.equal(response.status, 503);
    const json = await response.json();
    assert.equal(json.api, 'unreachable');
  } finally {
    await web.close();
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
});

test('GET /readyz passes when bundle and API are available', async () => {
  const buildDir = createFlutterBuildFixture();
  const api = await createApiStub();
  const web = await createWebServer({
    buildDir,
    apiUpstreamUrl: api.baseUrl,
  });

  try {
    const response = await fetch(`${web.baseUrl}/readyz`);
    assert.equal(response.status, 200);
    const json = await response.json();
    assert.deepEqual(json, {
      status: 'ok',
      service: 'web',
      build: 'ok',
      api: 'ok',
    });
  } finally {
    await web.close();
    await api.close();
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
});

test('GET /api/health proxies to the API service', async () => {
  const buildDir = createFlutterBuildFixture();
  const api = await createApiStub({
    apiHealthBody: JSON.stringify({ status: 'ok', proxied: true }),
  });
  const web = await createWebServer({
    buildDir,
    apiUpstreamUrl: api.baseUrl,
  });

  try {
    const response = await fetch(`${web.baseUrl}/api/health`);
    assert.equal(response.status, 200);
    const json = await response.json();
    assert.equal(json.proxied, true);
  } finally {
    await web.close();
    await api.close();
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
});

test('static bootstrap assets use no-store cache headers', async () => {
  const buildDir = createFlutterBuildFixture();
  const api = await createApiStub();
  const web = await createWebServer({
    buildDir,
    apiUpstreamUrl: api.baseUrl,
  });

  try {
    const response = await fetch(`${web.baseUrl}/main.dart.js`);
    assert.equal(response.status, 200);
    assert.equal(response.headers.get('cache-control'), 'no-store');
  } finally {
    await web.close();
    await api.close();
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
});

test('static hashed assets use immutable cache headers', async () => {
  const buildDir = createFlutterBuildFixture();
  const api = await createApiStub();
  const web = await createWebServer({
    buildDir,
    apiUpstreamUrl: api.baseUrl,
  });

  try {
    const response = await fetch(`${web.baseUrl}/assets/logo.txt`);
    assert.equal(response.status, 200);
    assert.equal(
      response.headers.get('cache-control'),
      'public, max-age=31536000, immutable'
    );
  } finally {
    await web.close();
    await api.close();
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
});

test('SPA routes fall back to index.html with no-store caching', async () => {
  const buildDir = createFlutterBuildFixture();
  const api = await createApiStub();
  const web = await createWebServer({
    buildDir,
    apiUpstreamUrl: api.baseUrl,
  });

  try {
    const response = await fetch(`${web.baseUrl}/dashboard/shift`);
    assert.equal(response.status, 200);
    assert.equal(response.headers.get('cache-control'), 'no-store');
    const body = await response.text();
    assert.match(body, /<body>app<\/body>/);
  } finally {
    await web.close();
    await api.close();
    fs.rmSync(buildDir, { recursive: true, force: true });
  }
});

test('non-health requests fail fast when the bundle is missing', async () => {
  const web = await createWebServer({
    buildDir: path.join(os.tmpdir(), 'missing-build-dir-routes'),
    apiUpstreamUrl: 'http://127.0.0.1:9',
  });

  try {
    const response = await fetch(`${web.baseUrl}/`);
    assert.equal(response.status, 503);
    const body = await response.text();
    assert.match(body, /Flutter web build missing/);
  } finally {
    await web.close();
  }
});
