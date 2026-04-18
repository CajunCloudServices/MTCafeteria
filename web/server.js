const express = require('express');
const fs = require('fs');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

function joinUrl(baseUrl, routePath) {
  return `${String(baseUrl).replace(/\/+$/, '')}${routePath}`;
}

function defaultBuildDir() {
  return path.join(__dirname, 'public', 'flutter-web');
}

function defaultFetchImpl() {
  if (typeof fetch !== 'function') {
    throw new Error('Global fetch is required for readiness probes.');
  }
  return fetch;
}

function hasFlutterBuild(indexFile) {
  return fs.existsSync(indexFile);
}

function sendBuildMissing(res) {
  res.status(503).type('text/plain').send(
    'Flutter web build missing from the image. Rebuild and redeploy the web service.'
  );
}

async function checkApiReadiness({
  apiUpstreamUrl,
  fetchImpl = defaultFetchImpl(),
  readinessTimeoutMs = 5000,
}) {
  const response = await fetchImpl(joinUrl(apiUpstreamUrl, '/health'), {
    signal: AbortSignal.timeout(readinessTimeoutMs),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`API upstream returned ${response.status}: ${text}`);
  }

  return response;
}

function createProxy({ target, routePrefix }) {
  return createProxyMiddleware({
    target,
    changeOrigin: true,
    ws: true,
    on: {
      error(error, req, res) {
        if (res.headersSent) {
          return;
        }
        res.statusCode = 502;
        res.setHeader('Content-Type', 'application/json');
        res.end(
          JSON.stringify({
            status: 'error',
            message: `Could not reach ${routePrefix} upstream.`,
            detail: error.message,
          })
        );
      },
    },
  });
}

function createApp(options = {}) {
  const app = express();
  const apiUpstreamUrl = options.apiUpstreamUrl || process.env.API_UPSTREAM_URL || 'http://api:4000';
  const buildDir = options.buildDir || defaultBuildDir();
  const indexFile = path.join(buildDir, 'index.html');
  const fetchImpl = options.fetchImpl || defaultFetchImpl();
  const readinessTimeoutMs = Number(
    options.readinessTimeoutMs || process.env.READINESS_TIMEOUT_MS || 5000
  );

  app.disable('x-powered-by');

  app.get('/health', (_req, res) => {
    res.json({
      status: 'ok',
      service: 'web',
      buildPresent: hasFlutterBuild(indexFile),
    });
  });

  app.get('/readyz', async (_req, res) => {
    if (!hasFlutterBuild(indexFile)) {
      res.status(503).json({
        status: 'degraded',
        service: 'web',
        build: 'missing',
        api: 'unknown',
        message:
          'Flutter web build missing from the image. Expected files under public/flutter-web.',
      });
      return;
    }

    try {
      await checkApiReadiness({
        apiUpstreamUrl,
        fetchImpl,
        readinessTimeoutMs,
      });
      res.json({
        status: 'ok',
        service: 'web',
        build: 'ok',
        api: 'ok',
      });
    } catch (error) {
      res.status(503).json({
        status: 'degraded',
        service: 'web',
        build: 'ok',
        api: 'unreachable',
        message: error.message,
      });
    }
  });

  app.use(
    '/api',
    createProxy({
      target: joinUrl(apiUpstreamUrl, '/api'),
      routePrefix: '/api',
    })
  );

  app.use(
    '/socket.io',
    createProxy({
      target: apiUpstreamUrl,
      routePrefix: '/socket.io',
    })
  );

  app.use((req, res, next) => {
    if (!hasFlutterBuild(indexFile)) {
      sendBuildMissing(res);
      return;
    }
    next();
  });

  app.use(
    express.static(buildDir, {
      index: false,
      setHeaders(res, filePath) {
        const name = path.basename(filePath);
        // Flutter's bootstrap chain uses stable filenames (not content-hashed),
        // so these must always revalidate to avoid stale edge-cache rollouts.
        if (
          name === 'index.html' ||
          name === 'main.dart.js' ||
          name === 'flutter_bootstrap.js' ||
          name === 'flutter.js' ||
          name === 'flutter_service_worker.js' ||
          name === 'MaterialIcons-Regular.otf' ||
          name === 'CupertinoIcons.ttf'
        ) {
          res.setHeader('Cache-Control', 'no-store');
          return;
        }
        res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
      },
    })
  );

  app.get('*', (_req, res) => {
    res.setHeader('Cache-Control', 'no-store');
    res.sendFile(indexFile);
  });

  return app;
}

function startServer(options = {}) {
  const app = createApp(options);
  const port = Number(options.port || process.env.PORT || 3000);
  return app.listen(port, () => {
    console.log(`MTC Cafeteria web server listening on http://0.0.0.0:${port}`);
  });
}

if (require.main === module) {
  startServer();
}

module.exports = {
  checkApiReadiness,
  createApp,
  hasFlutterBuild,
  startServer,
};
