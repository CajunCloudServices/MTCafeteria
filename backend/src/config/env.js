const dotenv = require('dotenv');

dotenv.config();

const nodeEnv = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';
const useMockDataInput = process.env.USE_MOCK_DATA;
const useMockData = useMockDataInput == null
  ? !isProduction
  : String(useMockDataInput).toLowerCase() === 'true';

const jwtSecret = process.env.JWT_SECRET || '';
if (!useMockData && !jwtSecret) {
  throw new Error('JWT_SECRET is required when USE_MOCK_DATA=false.');
}
if (isProduction && jwtSecret === 'dev-secret') {
  throw new Error('JWT_SECRET cannot be "dev-secret" in production.');
}

const corsOrigins = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map((value) => value.trim())
  .filter((value) => value.length > 0);

const env = {
  nodeEnv,
  isProduction,
  port: Number(process.env.PORT || 3201),
  databaseUrl: process.env.DATABASE_URL || '',
  jwtSecret: jwtSecret || 'dev-secret',
  useMockData,
  corsOrigins,
};

module.exports = env;
