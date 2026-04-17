const dotenv = require('dotenv');

dotenv.config();

const nodeEnv = process.env.NODE_ENV || 'development';
const isProduction = nodeEnv === 'production';
const useMockDataInput = process.env.USE_MOCK_DATA;
const useMockData = useMockDataInput == null
  ? !isProduction
  : String(useMockDataInput).toLowerCase() === 'true';

const BLOCKED_SECRET_VALUES = new Set([
  '',
  'dev-secret',
  'replace-with-strong-secret',
  'replace-with-strong-db-password',
  'replace-me',
  'changeme',
  'postgres',
  'yoboss',
]);

const BLOCKED_DATABASE_URLS = new Set([
  '',
  'postgresql://postgres:postgres@postgres:5432/mtc_cafeteria',
  'postgres://postgres:postgres@postgres:5432/mtc_cafeteria',
]);

function isPlaceholderSecret(value) {
  const normalized = String(value || '').trim();
  return (
    BLOCKED_SECRET_VALUES.has(normalized)
    || normalized.toLowerCase().includes('replace-with-')
    || normalized.toLowerCase().includes('replace-me')
  );
}

function isPlaceholderDatabaseUrl(value) {
  const normalized = String(value || '').trim();
  return (
    BLOCKED_DATABASE_URLS.has(normalized)
    || normalized.toLowerCase().includes('replace-with-')
    || normalized.toLowerCase().includes('replace-me')
  );
}

function assertConfigured(name, value, validator, requirementMessage, placeholderMessage) {
  if (!value) {
    throw new Error(requirementMessage);
  }
  if (validator(value)) {
    throw new Error(placeholderMessage);
  }
}

function parseBoolean(value, defaultValue) {
  if (value == null || value === '') return defaultValue;
  const normalized = String(value).trim().toLowerCase();
  if (['true', '1', 'yes', 'on'].includes(normalized)) return true;
  if (['false', '0', 'no', 'off'].includes(normalized)) return false;
  return defaultValue;
}

function parsePositiveInteger(value, defaultValue) {
  const parsed = Number(value);
  return Number.isInteger(parsed) && parsed > 0 ? parsed : defaultValue;
}

const jwtSecret = process.env.JWT_SECRET || '';
if (!useMockData && !jwtSecret) {
  throw new Error('JWT_SECRET is required when USE_MOCK_DATA=false.');
}
if (isProduction) {
  assertConfigured(
    'JWT_SECRET',
    jwtSecret,
    isPlaceholderSecret,
    'JWT_SECRET is required in production.',
    'JWT_SECRET must not use a placeholder or default value in production.'
  );
}

const databaseUrl = process.env.DATABASE_URL || '';
if (!useMockData && !databaseUrl) {
  throw new Error('DATABASE_URL is required when USE_MOCK_DATA=false.');
}
if (isProduction && !useMockData) {
  assertConfigured(
    'DATABASE_URL',
    databaseUrl,
    isPlaceholderDatabaseUrl,
    'DATABASE_URL is required in production when USE_MOCK_DATA=false.',
    'DATABASE_URL must not use a placeholder or default value in production.'
  );
}

const postgresPassword = process.env.POSTGRES_PASSWORD || '';
if (isProduction && postgresPassword) {
  assertConfigured(
    'POSTGRES_PASSWORD',
    postgresPassword,
    isPlaceholderSecret,
    'POSTGRES_PASSWORD is required in production when provided to the API.',
    'POSTGRES_PASSWORD must not use a placeholder or default value in production.'
  );
}

const taskEditorPassword = process.env.TASK_EDITOR_PASSWORD || '';
if (isProduction) {
  assertConfigured(
    'TASK_EDITOR_PASSWORD',
    taskEditorPassword,
    isPlaceholderSecret,
    'TASK_EDITOR_PASSWORD is required in production.',
    'TASK_EDITOR_PASSWORD must not use a placeholder or default value in production.'
  );
}

const corsOrigins = (process.env.CORS_ORIGINS || '')
  .split(',')
  .map((value) => value.trim())
  .filter((value) => value.length > 0);
if (isProduction && corsOrigins.length === 0) {
  throw new Error('CORS_ORIGINS must be set in production.');
}

const env = {
  nodeEnv,
  isProduction,
  port: Number(process.env.PORT || 3201),
  databaseUrl,
  jwtSecret: jwtSecret || 'dev-secret',
  useMockData,
  corsOrigins,
  chatbotProxyEnabled: parseBoolean(process.env.CHATBOT_PROXY_ENABLED, true),
  chatbotUpstreamUrl: String(process.env.CHATBOT_UPSTREAM_URL || '').trim(),
  chatbotApiToken: String(process.env.CHATBOT_API_TOKEN || '').trim(),
  chatbotTimeoutMs: Number(process.env.CHATBOT_TIMEOUT_MS || 65000),
  chatbotMaxMessageChars: parsePositiveInteger(process.env.CHATBOT_MAX_MESSAGE_CHARS, 300),
  chatbotMaxSessionIdChars: parsePositiveInteger(process.env.CHATBOT_MAX_SESSION_ID_CHARS, 120),
  chatbotRateLimitWindowMs: parsePositiveInteger(process.env.CHATBOT_RATE_LIMIT_WINDOW_MS, 60000),
  chatbotRateLimitMaxRequests: parsePositiveInteger(process.env.CHATBOT_RATE_LIMIT_MAX_REQUESTS, 6),
  chatbotMaxConcurrentRequests: parsePositiveInteger(process.env.CHATBOT_MAX_CONCURRENT_REQUESTS, 1),
  chatbotDuplicateCooldownMs: parsePositiveInteger(process.env.CHATBOT_DUPLICATE_COOLDOWN_MS, 15000),
};

module.exports = env;
