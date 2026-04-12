const express = require('express');
const fs = require('fs');
const path = require('path');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
const port = Number(process.env.PORT || 3000);
const apiUpstreamUrl = process.env.API_UPSTREAM_URL || 'http://api:4000';
const buildDir = path.join(__dirname, 'public', 'flutter-web');
const indexFile = path.join(buildDir, 'index.html');

app.disable('x-powered-by');

function hasFlutterBuild() {
  return fs.existsSync(indexFile);
}

function sendBuildMissing(res) {
  res.status(503).type('text/plain').send(
    'Flutter web build missing from the image. Rebuild and redeploy the web service.'
  );
}

app.get('/health', (req, res) => {
  if (!hasFlutterBuild()) {
    res.status(503).json({
      status: 'degraded',
      message:
        'Flutter web build missing from the image. Expected files under public/flutter-web.',
    });
    return;
  }

  res.json({ status: 'ok' });
});

app.use(
  '/api',
  createProxyMiddleware({
    target: `${apiUpstreamUrl}/api`,
    changeOrigin: true,
    ws: true,
  })
);

app.use(
  '/socket.io',
  createProxyMiddleware({
    target: apiUpstreamUrl,
    changeOrigin: true,
    ws: true,
  })
);

app.use((req, res, next) => {
  if (!hasFlutterBuild()) {
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
        name === 'flutter_service_worker.js'
      ) {
        res.setHeader('Cache-Control', 'no-store');
        return;
      }
      res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    },
  })
);

app.get('*', (req, res) => {
  res.setHeader('Cache-Control', 'no-store');
  res.sendFile(indexFile);
});

app.listen(port, () => {
  console.log(`MTC Cafeteria web server listening on http://0.0.0.0:${port}`);
});
