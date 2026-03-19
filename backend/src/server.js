const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
const env = require('./config/env');

const authRoutes = require('./routes/authRoutes');
const contentRoutes = require('./routes/contentRoutes');
const trainingRoutes = require('./routes/trainingRoutes');
const shiftRoutes = require('./routes/shiftRoutes');
const taskBoardRoutes = require('./routes/taskBoardRoutes');
const pointsRoutes = require('./routes/pointsRoutes');
const dailyShiftReportRoutes = require('./routes/dailyShiftReportRoutes');

const app = express();

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
      // Ignore parse errors for optional env files.
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
      callback(new Error('CORS origin not allowed.'));
    },
  })
);
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    mode: env.useMockData ? 'mock' : 'postgres',
    environment: env.nodeEnv,
  });
});

app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    mode: env.useMockData ? 'mock' : 'postgres',
    environment: env.nodeEnv,
  });
});

app.use('/api/auth', authRoutes);
app.use('/api/content', contentRoutes);
app.use('/api', trainingRoutes);
app.use('/api', shiftRoutes);
app.use('/api', taskBoardRoutes);
app.use('/api', pointsRoutes);
app.use('/api', dailyShiftReportRoutes);

app.use((error, req, res, next) => {
  // TODO: Replace with structured logger when observability is added.
  console.error(error);
  res.status(500).json({ message: 'Internal server error.' });
});

app.listen(env.port, () => {
  const configuredBackendPort = resolveConfiguredBackendPort();
  if (configuredBackendPort != null && configuredBackendPort !== env.port) {
    console.warn(
      `[WARN] Backend PORT (${env.port}) differs from BACKEND_PORT (${configuredBackendPort}) in env files.`
    );
  }
  console.log(`MTC Cafeteria backend running on http://localhost:${env.port}`);
});
