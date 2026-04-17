const { Pool } = require('pg');
const env = require('../config/env');

let pool;

if (!env.useMockData) {
  pool = new Pool({
    connectionString: env.databaseUrl,
  });
}

async function checkDatabaseHealth() {
  if (env.useMockData) {
    return {
      ok: true,
      type: 'mock',
    };
  }

  if (!pool) {
    return {
      ok: false,
      type: 'postgres',
      message: 'Database pool is not configured.',
    };
  }

  try {
    await pool.query('SELECT 1');
    return {
      ok: true,
      type: 'postgres',
    };
  } catch (_error) {
    return {
      ok: false,
      type: 'postgres',
      message: 'Database unavailable.',
    };
  }
}

module.exports = { pool, checkDatabaseHealth };
