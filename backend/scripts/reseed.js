#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const databaseUrl = process.env.DATABASE_URL;

if (!databaseUrl) {
  console.error('DATABASE_URL is required.');
  process.exit(1);
}

const sqlDir = path.resolve(__dirname, '..', 'sql');
const schemaSql = fs.readFileSync(path.join(sqlDir, 'schema.sql'), 'utf8');
const seedSql = fs.readFileSync(path.join(sqlDir, 'seed.sql'), 'utf8');

async function main() {
  const client = new Client({ connectionString: databaseUrl });
  await client.connect();

  try {
    console.log('Applying schema.sql...');
    await client.query(schemaSql);

    console.log('Applying seed.sql...');
    await client.query(seedSql);

    const counts = await client.query(`
      SELECT
        (SELECT COUNT(*)::int FROM shifts) AS shifts,
        (SELECT COUNT(*)::int FROM jobs) AS jobs,
        (SELECT COUNT(*)::int FROM tasks) AS tasks
    `);

    const duplicateJobs = await client.query(`
      SELECT s.meal_type, s.name AS shift_name, j.name, COUNT(*)::int AS copies
      FROM jobs j
      JOIN shifts s ON s.id = j.shift_id
      GROUP BY s.meal_type, s.name, j.name
      HAVING COUNT(*) > 1
      ORDER BY copies DESC, s.meal_type, j.name
      LIMIT 20
    `);

    console.log('Done.');
    console.log(JSON.stringify({
      counts: counts.rows[0],
      duplicateJobGroups: duplicateJobs.rows,
    }, null, 2));
  } finally {
    await client.end();
  }
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
