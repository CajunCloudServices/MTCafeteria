#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  console.error('DATABASE_URL is required.');
  process.exit(1);
}

const migrationsDir = path.resolve(__dirname, '..', 'sql', 'migrations');

function getMigrationFiles() {
  if (!fs.existsSync(migrationsDir)) {
    return [];
  }

  return fs.readdirSync(migrationsDir)
    .filter((fileName) => fileName.endsWith('.sql'))
    .sort();
}

async function ensureSchemaMigrationsTable(client) {
  await client.query(`
    CREATE TABLE IF NOT EXISTS schema_migrations (
      version VARCHAR(255) PRIMARY KEY,
      applied_at TIMESTAMP NOT NULL DEFAULT NOW()
    )
  `);
}

async function getAppliedVersions(client) {
  const result = await client.query('SELECT version FROM schema_migrations');
  return new Set(result.rows.map((row) => row.version));
}

async function applyMigration(client, fileName) {
  const migrationPath = path.join(migrationsDir, fileName);
  const sql = fs.readFileSync(migrationPath, 'utf8');

  await client.query('BEGIN');
  try {
    await client.query(sql);
    await client.query(
      'INSERT INTO schema_migrations (version) VALUES ($1) ON CONFLICT (version) DO NOTHING',
      [fileName]
    );
    await client.query('COMMIT');
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  }
}

async function main() {
  const migrationFiles = getMigrationFiles();
  const client = new Client({ connectionString: databaseUrl });
  await client.connect();

  try {
    await ensureSchemaMigrationsTable(client);
    const appliedVersions = await getAppliedVersions(client);

    for (const fileName of migrationFiles) {
      if (appliedVersions.has(fileName)) {
        continue;
      }

      console.log(`Applying migration ${fileName}...`);
      await applyMigration(client, fileName);
    }

    console.log('Migrations complete.');
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
