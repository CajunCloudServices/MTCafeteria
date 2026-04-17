const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const env = require('./config/env');
const asyncHandler = require('./middleware/asyncHandler');
const { checkDatabaseHealth } = require('./db/pool');

const authRoutes = require('./routes/authRoutes');
const contentRoutes = require('./routes/contentRoutes');
const trainingRoutes = require('./routes/trainingRoutes');
const shiftRoutes = require('./routes/shiftRoutes');
const taskBoardRoutes = require('./routes/taskBoardRoutes');
const taskAdminRoutes = require('./routes/taskAdminRoutes');
const pointsRoutes = require('./routes/pointsRoutes');
const dailyShiftReportRoutes = require('./routes/dailyShiftReportRoutes');

const app = express();

class CorsOriginError extends Error {
  constructor(origin) {
    super(`CORS origin not allowed: ${origin}`);
    this.name = 'CorsOriginError';
    this.statusCode = 403;
    this.expose = true;
  }
}

function resolveConfiguredBackendPort() {
  const candidates = [
    path.resolve(process.cwd(), '.env'),
    path.resolve(process.cwd(), '../.env'),
    path.resolve(process.cwd(), '../.env.example'),
  ];

  for (const file of candidates) {
    try {
      if (!fs.existsSync(file)) continue;
      const parsed = dotenv.parse(fs.readFileSync(file));
      const value = Number(parsed.BACKEND_PORT);
      if (Number.isInteger(value) && value > 0) {
        return value;
      }
    } catch (_) {
      // Optional env files are allowed to fail silently.
    }
  }
  return null;
}

app.use(
  cors({
    origin(origin, callback) {
      if (!origin || env.corsOrigins.length === 0 || env.corsOrigins.includes(origin)) {
        callback(null, true);
        return;
      }
      callback(new CorsOriginError(origin));
    },
  })
);
app.use(express.json({ limit: '1mb' }));

async function healthResponse() {
  const database = await checkDatabaseHealth();
  return {
    status: database.ok ? 'ok' : 'degraded',
    mode: env.useMockData ? 'mock' : 'postgres',
    environment: env.nodeEnv,
    dependencies: {
      database: {
        status: database.ok ? 'ok' : 'unavailable',
        type: database.type,
        ...(database.message ? { message: database.message } : {}),
      },
    },
  };
}

async function sendReadiness(res) {
  const payload = await healthResponse();
  res.status(payload.status === 'ok' ? 200 : 503).json(payload);
}

app.get('/livez', (_req, res) => {
  res.json({
    status: 'ok',
    mode: env.useMockData ? 'mock' : 'postgres',
    environment: env.nodeEnv,
  });
});
app.get('/readyz', asyncHandler(async (_req, res) => sendReadiness(res)));
app.get('/health', asyncHandler(async (_req, res) => sendReadiness(res)));
app.get('/api/health', asyncHandler(async (_req, res) => sendReadiness(res)));
app.get('/api/readyz', asyncHandler(async (_req, res) => sendReadiness(res)));

app.use('/api/auth', authRoutes);
app.use('/api/content', contentRoutes);
app.use('/api', trainingRoutes);
app.use('/api', shiftRoutes);
app.use('/api', taskBoardRoutes);
app.use('/api', taskAdminRoutes);
app.use('/api', pointsRoutes);
app.use('/api', dailyShiftReportRoutes);

app.use((_req, res) => {
  res.status(404).json({ message: 'Not found.' });
});

// eslint-disable-next-line no-unused-vars
app.use((error, req, res, _next) => {
  if (error instanceof CorsOriginError) {
    res.status(error.statusCode).json({ message: error.message });
    return;
  }
  // TODO: Replace with structured logger when observability is added.
  console.error(error);
  const status = Number.isInteger(error?.statusCode) ? error.statusCode : 500;
  const message = error?.expose && error?.message ? error.message : 'Internal server error.';
  res.status(status).json({ message });
});

if (require.main === module) {
  app.listen(env.port, () => {
    const configuredBackendPort = resolveConfiguredBackendPort();
    if (configuredBackendPort != null && configuredBackendPort !== env.port) {
      console.warn(
        `[WARN] Backend PORT (${env.port}) differs from BACKEND_PORT (${configuredBackendPort}) in env files.`
      );
    }
    console.log(`MTC Cafeteria backend running on http://localhost:${env.port}`);
  });
}

module.exports = app;
