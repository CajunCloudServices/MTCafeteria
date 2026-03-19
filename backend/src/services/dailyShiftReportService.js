const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');
const { Roles } = require('../config/roles');

const MEALS = ['Breakfast', 'Lunch', 'Dinner'];
const TRACK = 'Line';

const REQUIRED_FIELDS = [
  'count',
  'late',
  'sick',
  'noShows',
  'deepClean',
  'seniorCashier',
  'juniorCashier',
  'specialtyMealsAttendantAndPlateCount',
  'oneOnOne',
  'shiftShoutout',
  'entreeItemOutage',
  'productOutage',
  'productSurplus',
  'lockersChecked',
  'maintenanceConcerns',
  'generalComments',
  'trainings',
  'serviceMissionariesPresentForShift',
  'summaries',
];

const PILOT_EXCLUDED_REQUIRED_FIELDS = new Set([
  'late',
  'sick',
  'noShows',
  'seniorCashier',
  'juniorCashier',
  'specialtyMealsAttendantAndPlateCount',
  'oneOnOne',
  'shiftShoutout',
  'trainings',
  'serviceMissionariesPresentForShift',
]);

function normalizeMeal(mealInput) {
  return MEALS.includes(mealInput) ? mealInput : 'Breakfast';
}

function normalizePayload(payload) {
  const source = payload && typeof payload === 'object' ? payload : {};
  const result = {};

  const allKeys = [
    ...REQUIRED_FIELDS,
    'cafeWestCount',
    'alohaPlateCount',
    'choicesCount',
    'juniorCashCount',
    'seniorCashCount',
    'sackRoomCount',
    'sackCount',
    'sackCashier',
    'dinnerChoicesAlohaPerson',
  ];

  for (const key of allKeys) {
    const value = source[key];
    result[key] = value == null ? '' : String(value).trim();
  }

  return result;
}

function assertSupervisorRole(role) {
  if (role !== Roles.SUPERVISOR && role !== Roles.STUDENT_MANAGER) {
    throw new Error('Unauthorized');
  }
}

function assertLeadershipRole(role) {
  if (
    role !== Roles.SUPERVISOR &&
    role !== Roles.STUDENT_MANAGER &&
    role !== Roles.LEAD_TRAINER &&
    role !== Roles.DISHROOM_LEAD_TRAINER
  ) {
    throw new Error('Unauthorized');
  }
}

function isPilotProfile(appProfile) {
  return String(appProfile || '').trim().toLowerCase() === 'pilot';
}

function requiredFieldsForProfile(appProfile) {
  if (!isPilotProfile(appProfile)) {
    return REQUIRED_FIELDS;
  }
  return REQUIRED_FIELDS.filter(
    (key) => !PILOT_EXCLUDED_REQUIRED_FIELDS.has(key)
  );
}

function assertPayloadComplete(payload, { appProfile } = {}) {
  const normalized = normalizePayload(payload);
  const missing = requiredFieldsForProfile(appProfile).filter(
    (key) => normalized[key].length === 0
  );
  if (missing.length > 0) {
    const error = new Error('Incomplete');
    error.missingFields = missing;
    throw error;
  }
}

function toResponse(row) {
  return {
    id: row.id,
    reportDate: row.report_date || row.reportDate,
    mealType: row.meal_type || row.mealType,
    track: row.track,
    status: row.status,
    submittedByUserId: row.submitted_by_user_id || row.submittedByUserId,
    submittedByEmail: row.submitted_by_email || row.submittedByEmail,
    submittedAt: row.submitted_at || row.submittedAt,
    createdAt: row.created_at || row.createdAt,
    updatedAt: row.updated_at || row.updatedAt,
    payload: row.payload || {},
  };
}

function todayDateString() {
  return new Date().toISOString().slice(0, 10);
}

function findMockReport({ requesterUserId, selectedMeal, reportDate }) {
  return (mockData.dailyShiftReports || []).find(
    (item) =>
      item.track === TRACK &&
      item.mealType === selectedMeal &&
      item.reportDate === reportDate &&
      item.submittedByUserId === requesterUserId
  );
}

function upsertMockReport({
  requesterUserId,
  selectedMeal,
  reportDate,
  normalizedPayload,
  status,
}) {
  if (!mockData.dailyShiftReports) {
    mockData.dailyShiftReports = [];
  }

  const now = new Date().toISOString();
  let report = findMockReport({ requesterUserId, selectedMeal, reportDate });

  if (!report) {
    const id =
      Math.max(0, ...mockData.dailyShiftReports.map((item) => item.id || 0)) + 1;
    const user = mockData.users.find((u) => u.id === requesterUserId);
    report = {
      id,
      reportDate,
      mealType: selectedMeal,
      track: TRACK,
      status,
      submittedByUserId: requesterUserId,
      submittedByEmail: user?.email || null,
      submittedAt: status === 'Submitted' ? now : null,
      createdAt: now,
      updatedAt: now,
      payload: normalizedPayload,
    };
    mockData.dailyShiftReports.push(report);
  } else {
    report.payload = normalizedPayload;
    report.status = status;
    report.submittedAt = status === 'Submitted' ? now : null;
    report.updatedAt = now;
  }

  return report;
}

async function upsertReportInDb({
  reportDate,
  selectedMeal,
  requesterUserId,
  normalizedPayload,
  status,
}) {
  const submittedAtSql = status === 'Submitted' ? 'NOW()' : 'NULL';

  const { rows } = await pool.query(
    `
      INSERT INTO daily_shift_reports (
        report_date,
        meal_type,
        track,
        status,
        submitted_by_user_id,
        payload,
        submitted_at,
        updated_at
      )
      VALUES ($1, $2, $3, $4, $5, $6::jsonb, ${submittedAtSql}, NOW())
      ON CONFLICT (report_date, meal_type, track, submitted_by_user_id)
      DO UPDATE
      SET
        payload = EXCLUDED.payload,
        status = EXCLUDED.status,
        submitted_at = ${submittedAtSql},
        updated_at = NOW()
      RETURNING id;
    `,
    [reportDate, selectedMeal, TRACK, status, requesterUserId, JSON.stringify(normalizedPayload)]
  );

  return loadById(rows[0]?.id);
}

async function getCurrentLineShiftReport({ requesterUserId, requesterRole, meal }) {
  assertSupervisorRole(requesterRole);
  const selectedMeal = normalizeMeal(meal);
  const reportDate = todayDateString();

  if (env.useMockData) {
    return findMockReport({ requesterUserId, selectedMeal, reportDate }) || null;
  }

  const { rows } = await pool.query(
    `
      SELECT
        dsr.id,
        dsr.report_date,
        dsr.meal_type,
        dsr.track,
        dsr.status,
        dsr.submitted_by_user_id,
        u.email AS submitted_by_email,
        dsr.submitted_at,
        dsr.created_at,
        dsr.updated_at,
        dsr.payload
      FROM daily_shift_reports dsr
      JOIN users u ON u.id = dsr.submitted_by_user_id
      WHERE dsr.track = $1
        AND dsr.meal_type = $2
        AND dsr.report_date = $3
        AND dsr.submitted_by_user_id = $4
      LIMIT 1;
    `,
    [TRACK, selectedMeal, reportDate, requesterUserId]
  );

  return rows[0] ? toResponse(rows[0]) : null;
}

async function saveLineShiftReportDraft({ requesterUserId, requesterRole, meal, payload }) {
  assertSupervisorRole(requesterRole);
  const selectedMeal = normalizeMeal(meal);
  const reportDate = todayDateString();
  const normalizedPayload = normalizePayload(payload);

  if (env.useMockData) {
    return upsertMockReport({
      requesterUserId,
      selectedMeal,
      reportDate,
      normalizedPayload,
      status: 'Draft',
    });
  }
  return upsertReportInDb({
    reportDate,
    selectedMeal,
    requesterUserId,
    normalizedPayload,
    status: 'Draft',
  });
}

async function submitLineShiftReport({
  requesterUserId,
  requesterRole,
  meal,
  payload,
  appProfile,
}) {
  assertSupervisorRole(requesterRole);
  assertPayloadComplete(payload, { appProfile });

  const selectedMeal = normalizeMeal(meal);
  const reportDate = todayDateString();
  const normalizedPayload = normalizePayload(payload);

  if (env.useMockData) {
    return upsertMockReport({
      requesterUserId,
      selectedMeal,
      reportDate,
      normalizedPayload,
      status: 'Submitted',
    });
  }
  return upsertReportInDb({
    reportDate,
    selectedMeal,
    requesterUserId,
    normalizedPayload,
    status: 'Submitted',
  });
}

async function listLineShiftReportsForLeadership({ requesterRole }) {
  assertLeadershipRole(requesterRole);

  if (env.useMockData) {
    return (mockData.dailyShiftReports || [])
      .filter((item) => item.track === TRACK && item.status === 'Submitted')
      .sort((a, b) => {
        const dateCompare = (b.reportDate || '').localeCompare(a.reportDate || '');
        if (dateCompare !== 0) return dateCompare;
        return (b.submittedAt || '').localeCompare(a.submittedAt || '');
      });
  }

  const { rows } = await pool.query(
    `
      SELECT
        dsr.id,
        dsr.report_date,
        dsr.meal_type,
        dsr.track,
        dsr.status,
        dsr.submitted_by_user_id,
        u.email AS submitted_by_email,
        dsr.submitted_at,
        dsr.created_at,
        dsr.updated_at,
        dsr.payload
      FROM daily_shift_reports dsr
      JOIN users u ON u.id = dsr.submitted_by_user_id
      WHERE dsr.track = $1
        AND dsr.status = 'Submitted'
      ORDER BY dsr.report_date DESC, dsr.submitted_at DESC, dsr.id DESC;
    `,
    [TRACK]
  );

  return rows.map(toResponse);
}

async function loadById(reportId) {
  if (!reportId) {
    return null;
  }

  const { rows } = await pool.query(
    `
      SELECT
        dsr.id,
        dsr.report_date,
        dsr.meal_type,
        dsr.track,
        dsr.status,
        dsr.submitted_by_user_id,
        u.email AS submitted_by_email,
        dsr.submitted_at,
        dsr.created_at,
        dsr.updated_at,
        dsr.payload
      FROM daily_shift_reports dsr
      JOIN users u ON u.id = dsr.submitted_by_user_id
      WHERE dsr.id = $1
      LIMIT 1;
    `,
    [reportId]
  );

  return rows[0] ? toResponse(rows[0]) : null;
}

module.exports = {
  REQUIRED_FIELDS,
  normalizePayload,
  getCurrentLineShiftReport,
  saveLineShiftReportDraft,
  submitLineShiftReport,
  listLineShiftReportsForLeadership,
};
