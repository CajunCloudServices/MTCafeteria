const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');

function defaultLandingItems() {
  return dedupeAnnouncements(mockData.announcements.map(normalizeAnnouncement));
}

function normalizeAnnouncement(row) {
  return {
    id: row.id,
    type: row.type,
    title: row.title,
    content: row.content,
    startDate: row.start_date || row.startDate,
    endDate: row.end_date || row.endDate,
    createdBy: row.created_by || row.createdBy,
  };
}

function announcementFingerprint(item) {
  // Duplicate rows often differ only by DB id.
  // Fingerprint the content fields so list responses stay clean.
  const safe = (value) => String(value ?? '').trim().toLowerCase();
  return [
    safe(item.type),
    safe(item.title),
    safe(item.content),
    safe(item.startDate),
    safe(item.endDate),
  ].join('|');
}

function dedupeAnnouncements(items) {
  const seen = new Set();
  const unique = [];
  for (const item of items) {
    const key = announcementFingerprint(item);
    if (seen.has(key)) continue;
    seen.add(key);
    unique.push(item);
  }
  return unique;
}

async function listLandingItems() {
  if (env.useMockData) {
    return defaultLandingItems();
  }

  const { rows } = await pool.query(
    `SELECT id, type, title, content, start_date, end_date, created_by FROM announcements ORDER BY start_date DESC, id DESC;`
  );
  if (rows.length === 0) {
    // Production deploys should keep the baseline landing cards visible even
    // if the announcements table has not been reseeded yet.
    return defaultLandingItems();
  }
  return dedupeAnnouncements(rows.map(normalizeAnnouncement));
}

async function createLandingItem(item) {
  if (env.useMockData) {
    const id = Math.max(0, ...mockData.announcements.map((a) => a.id)) + 1;
    const newItem = { id, ...item };
    mockData.announcements.push(newItem);
    return newItem;
  }

  const { rows } = await pool.query(
    `
      INSERT INTO announcements (type, title, content, start_date, end_date, created_by)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING id, type, title, content, start_date, end_date, created_by;
    `,
    [item.type, item.title, item.content, item.startDate, item.endDate, item.createdBy]
  );
  return normalizeAnnouncement(rows[0]);
}

async function updateLandingItem(id, item) {
  if (env.useMockData) {
    const index = mockData.announcements.findIndex((a) => a.id === Number(id));
    if (index === -1) return null;
    mockData.announcements[index] = { ...mockData.announcements[index], ...item };
    return mockData.announcements[index];
  }

  const { rows } = await pool.query(
    `
      UPDATE announcements
      SET type = $2, title = $3, content = $4, start_date = $5, end_date = $6
      WHERE id = $1
      RETURNING id, type, title, content, start_date, end_date, created_by;
    `,
    [id, item.type, item.title, item.content, item.startDate, item.endDate]
  );
  return rows[0] ? normalizeAnnouncement(rows[0]) : null;
}

async function deleteLandingItem(id) {
  if (env.useMockData) {
    const index = mockData.announcements.findIndex((a) => a.id === Number(id));
    if (index === -1) return false;
    mockData.announcements.splice(index, 1);
    return true;
  }

  const result = await pool.query('DELETE FROM announcements WHERE id = $1;', [id]);
  return result.rowCount > 0;
}

module.exports = {
  listLandingItems,
  createLandingItem,
  updateLandingItem,
  deleteLandingItem,
};
