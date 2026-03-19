const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');

// Legacy prototype training feed. This service remains available for older
// dashboard flows, while the active detailed 2-minute training viewer is
// sourced from the frontend's manual local corpus.
function toTraining(row) {
  return {
    id: row.id,
    title: row.title,
    content: row.content,
    assignedDate: row.assigned_date || row.assignedDate,
  };
}

async function listTrainings() {
  if (env.useMockData) {
    return mockData.trainings;
  }

  const { rows } = await pool.query('SELECT id, title, content, assigned_date FROM trainings ORDER BY assigned_date DESC, id DESC;');
  return rows.map(toTraining);
}

module.exports = {
  listTrainings,
};
