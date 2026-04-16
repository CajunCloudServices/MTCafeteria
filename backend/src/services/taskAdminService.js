const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');
const mockStore = require('../db/taskEditorMockStore');

const PHASES = ['Setup', 'During Shift', 'Cleanup'];

class ValidationError extends Error {
  constructor(message) {
    super(message);
    this.name = 'ValidationError';
    this.statusCode = 400;
    this.expose = true;
  }
}

class NotFoundError extends Error {
  constructor(message) {
    super(message);
    this.name = 'NotFoundError';
    this.statusCode = 404;
    this.expose = true;
  }
}

function normalizePhase(value) {
  if (typeof value !== 'string') return null;
  const trimmed = value.trim();
  return PHASES.find((phase) => phase.toLowerCase() === trimmed.toLowerCase()) || null;
}

function requireName(raw, label) {
  if (typeof raw !== 'string' || raw.trim().length === 0) {
    throw new ValidationError(`${label} is required.`);
  }
  if (raw.trim().length > 200) {
    throw new ValidationError(`${label} must be 200 characters or fewer.`);
  }
  return raw.trim();
}

function requireInteger(raw, label) {
  const value = Number.parseInt(String(raw), 10);
  if (!Number.isInteger(value) || value <= 0) {
    throw new ValidationError(`${label} must be a positive integer.`);
  }
  return value;
}

function requireDescription(raw) {
  if (typeof raw !== 'string' || raw.trim().length === 0) {
    throw new ValidationError('description is required.');
  }
  if (raw.trim().length > 2000) {
    throw new ValidationError('description must be 2000 characters or fewer.');
  }
  return raw.trim();
}

function requirePhase(raw) {
  const phase = normalizePhase(raw);
  if (!phase) {
    throw new ValidationError(
      `phase must be one of: ${PHASES.join(', ')}.`
    );
  }
  return phase;
}

function coerceBool(value, fallback) {
  if (typeof value === 'boolean') return value;
  if (typeof value === 'string') {
    const lowered = value.toLowerCase();
    if (lowered === 'true') return true;
    if (lowered === 'false') return false;
  }
  return fallback;
}

function buildJobPayload(job, tasks) {
  const shift = mockData.shifts.find((s) => s.id === job.shiftId);
  const jobTasks = tasks.filter((task) => task.jobId === job.id);
  const phaseBuckets = PHASES.reduce((acc, phase) => {
    acc[phase] = jobTasks
      .filter((task) => task.phase === phase)
      .map((task) => ({
        id: task.id,
        jobId: task.jobId,
        phase: task.phase,
        description: task.description,
        requiresCheckoff: task.requiresCheckoff !== false,
      }))
      .sort((a, b) => a.id - b.id);
    return acc;
  }, {});

  return {
    id: job.id,
    shiftId: job.shiftId,
    name: job.name,
    shiftName: shift?.name || null,
    mealType: shift?.mealType || null,
    tasks: phaseBuckets,
    totalTaskCount: jobTasks.length,
  };
}

async function listBoardForMock() {
  mockStore.ensureLoaded();
  const shifts = mockData.shifts
    .map((shift) => ({
      id: shift.id,
      shiftType: shift.shiftType,
      mealType: shift.mealType,
      name: shift.name,
    }))
    .sort((a, b) => a.id - b.id);

  const jobs = [...mockData.jobs]
    .sort((a, b) => {
      const shiftA = mockData.shifts.find((s) => s.id === a.shiftId);
      const shiftB = mockData.shifts.find((s) => s.id === b.shiftId);
      const mealCompare = String(shiftA?.mealType || '').localeCompare(
        String(shiftB?.mealType || '')
      );
      if (mealCompare !== 0) return mealCompare;
      return a.name.localeCompare(b.name);
    })
    .map((job) => buildJobPayload(job, mockData.tasks));

  return { shifts, jobs, phases: PHASES };
}

async function listBoardForPostgres() {
  const shiftsResult = await pool.query(
    'SELECT id, shift_type AS "shiftType", meal_type AS "mealType", name FROM shifts ORDER BY id;'
  );
  const jobsResult = await pool.query(
    'SELECT id, shift_id AS "shiftId", name FROM jobs ORDER BY name, id;'
  );
  const tasksResult = await pool.query(
    'SELECT id, job_id AS "jobId", phase, description FROM tasks ORDER BY id;'
  );

  const shifts = shiftsResult.rows;
  const shiftLookup = new Map(shifts.map((shift) => [shift.id, shift]));

  const jobs = jobsResult.rows
    .map((job) => {
      const shift = shiftLookup.get(job.shiftId);
      const jobTasks = tasksResult.rows.filter((task) => task.jobId === job.id);
      const phaseBuckets = PHASES.reduce((acc, phase) => {
        acc[phase] = jobTasks
          .filter((task) => task.phase === phase)
          .map((task) => ({
            id: task.id,
            jobId: task.jobId,
            phase: task.phase,
            description: task.description,
            requiresCheckoff: task.phase !== 'During Shift',
          }));
        return acc;
      }, {});
      return {
        id: job.id,
        shiftId: job.shiftId,
        name: job.name,
        shiftName: shift?.name || null,
        mealType: shift?.mealType || null,
        tasks: phaseBuckets,
        totalTaskCount: jobTasks.length,
      };
    })
    .sort((a, b) => {
      const mealCompare = String(a.mealType || '').localeCompare(
        String(b.mealType || '')
      );
      if (mealCompare !== 0) return mealCompare;
      return a.name.localeCompare(b.name);
    });

  return { shifts, jobs, phases: PHASES };
}

async function listBoard() {
  if (env.useMockData) {
    return listBoardForMock();
  }
  return listBoardForPostgres();
}

async function createJob({ name, shiftId }) {
  const resolvedName = requireName(name, 'name');
  const resolvedShiftId = requireInteger(shiftId, 'shiftId');

  if (env.useMockData) {
    mockStore.ensureLoaded();
    const shift = mockData.shifts.find((s) => s.id === resolvedShiftId);
    if (!shift) {
      throw new NotFoundError('Shift not found.');
    }
    const job = {
      id: mockStore.nextId(mockData.jobs),
      shiftId: resolvedShiftId,
      name: resolvedName,
    };
    mockData.jobs.push(job);
    mockStore.saveSnapshot();
    return buildJobPayload(job, mockData.tasks);
  }

  const shiftResult = await pool.query('SELECT id FROM shifts WHERE id = $1;', [resolvedShiftId]);
  if (shiftResult.rowCount === 0) {
    throw new NotFoundError('Shift not found.');
  }
  const result = await pool.query(
    'INSERT INTO jobs (shift_id, name) VALUES ($1, $2) RETURNING id, shift_id AS "shiftId", name;',
    [resolvedShiftId, resolvedName]
  );
  const job = result.rows[0];
  return {
    id: job.id,
    shiftId: job.shiftId,
    name: job.name,
    tasks: PHASES.reduce((acc, phase) => ({ ...acc, [phase]: [] }), {}),
    totalTaskCount: 0,
  };
}

async function updateJob(jobId, { name }) {
  const id = requireInteger(jobId, 'jobId');
  const resolvedName = requireName(name, 'name');

  if (env.useMockData) {
    mockStore.ensureLoaded();
    const job = mockData.jobs.find((j) => j.id === id);
    if (!job) {
      throw new NotFoundError('Job not found.');
    }
    job.name = resolvedName;
    mockStore.saveSnapshot();
    return buildJobPayload(job, mockData.tasks);
  }

  const result = await pool.query(
    'UPDATE jobs SET name = $2 WHERE id = $1 RETURNING id, shift_id AS "shiftId", name;',
    [id, resolvedName]
  );
  if (result.rowCount === 0) {
    throw new NotFoundError('Job not found.');
  }
  const job = result.rows[0];
  const tasksResult = await pool.query(
    'SELECT id, job_id AS "jobId", phase, description FROM tasks WHERE job_id = $1 ORDER BY id;',
    [id]
  );
  return buildJobPayload(job, tasksResult.rows);
}

async function deleteJob(jobId) {
  const id = requireInteger(jobId, 'jobId');

  if (env.useMockData) {
    mockStore.ensureLoaded();
    const index = mockData.jobs.findIndex((job) => job.id === id);
    if (index === -1) {
      throw new NotFoundError('Job not found.');
    }
    mockData.jobs.splice(index, 1);
    const remainingTasks = mockData.tasks.filter((task) => task.jobId !== id);
    mockData.tasks.splice(0, mockData.tasks.length, ...remainingTasks);
    mockStore.saveSnapshot();
    return;
  }

  const result = await pool.query('DELETE FROM jobs WHERE id = $1;', [id]);
  if (result.rowCount === 0) {
    throw new NotFoundError('Job not found.');
  }
}

async function createTask(jobId, { description, phase, requiresCheckoff }) {
  const resolvedJobId = requireInteger(jobId, 'jobId');
  const resolvedDescription = requireDescription(description);
  const resolvedPhase = requirePhase(phase);
  const resolvedRequires = coerceBool(requiresCheckoff, resolvedPhase !== 'During Shift');

  if (env.useMockData) {
    mockStore.ensureLoaded();
    const job = mockData.jobs.find((j) => j.id === resolvedJobId);
    if (!job) {
      throw new NotFoundError('Job not found.');
    }
    const task = {
      id: mockStore.nextId(mockData.tasks),
      jobId: resolvedJobId,
      phase: resolvedPhase,
      description: resolvedDescription,
      requiresCheckoff: resolvedRequires,
    };
    mockData.tasks.push(task);
    mockStore.saveSnapshot();
    return { ...task };
  }

  const jobResult = await pool.query('SELECT id FROM jobs WHERE id = $1;', [resolvedJobId]);
  if (jobResult.rowCount === 0) {
    throw new NotFoundError('Job not found.');
  }

  const result = await pool.query(
    `INSERT INTO tasks (job_id, phase, description)
     VALUES ($1, $2, $3)
     RETURNING id, job_id AS "jobId", phase, description;`,
    [resolvedJobId, resolvedPhase, resolvedDescription]
  );
  const task = result.rows[0];
  return {
    id: task.id,
    jobId: task.jobId,
    phase: task.phase,
    description: task.description,
    requiresCheckoff: resolvedRequires,
  };
}

async function updateTask(taskId, { description, phase, requiresCheckoff }) {
  const id = requireInteger(taskId, 'taskId');

  if (env.useMockData) {
    mockStore.ensureLoaded();
    const task = mockData.tasks.find((t) => t.id === id);
    if (!task) {
      throw new NotFoundError('Task not found.');
    }
    if (description !== undefined) {
      task.description = requireDescription(description);
    }
    if (phase !== undefined) {
      task.phase = requirePhase(phase);
    }
    if (requiresCheckoff !== undefined) {
      task.requiresCheckoff = coerceBool(requiresCheckoff, task.phase !== 'During Shift');
    }
    mockStore.saveSnapshot();
    return { ...task };
  }

  const fields = [];
  const values = [];
  if (description !== undefined) {
    values.push(requireDescription(description));
    fields.push(`description = $${values.length}`);
  }
  if (phase !== undefined) {
    values.push(requirePhase(phase));
    fields.push(`phase = $${values.length}`);
  }
  if (fields.length === 0) {
    const current = await pool.query(
      'SELECT id, job_id AS "jobId", phase, description FROM tasks WHERE id = $1;',
      [id]
    );
    if (current.rowCount === 0) {
      throw new NotFoundError('Task not found.');
    }
    const task = current.rows[0];
    return {
      id: task.id,
      jobId: task.jobId,
      phase: task.phase,
      description: task.description,
      requiresCheckoff: task.phase !== 'During Shift',
    };
  }
  values.push(id);
  const result = await pool.query(
    `UPDATE tasks
       SET ${fields.join(', ')}
     WHERE id = $${values.length}
     RETURNING id, job_id AS "jobId", phase, description;`,
    values
  );
  if (result.rowCount === 0) {
    throw new NotFoundError('Task not found.');
  }
  const task = result.rows[0];
  return {
    id: task.id,
    jobId: task.jobId,
    phase: task.phase,
    description: task.description,
    requiresCheckoff: task.phase !== 'During Shift',
  };
}

async function deleteTask(taskId) {
  const id = requireInteger(taskId, 'taskId');

  if (env.useMockData) {
    mockStore.ensureLoaded();
    const index = mockData.tasks.findIndex((task) => task.id === id);
    if (index === -1) {
      throw new NotFoundError('Task not found.');
    }
    mockData.tasks.splice(index, 1);
    mockStore.saveSnapshot();
    return;
  }

  const result = await pool.query('DELETE FROM tasks WHERE id = $1;', [id]);
  if (result.rowCount === 0) {
    throw new NotFoundError('Task not found.');
  }
}

module.exports = {
  PHASES,
  ValidationError,
  NotFoundError,
  listBoard,
  createJob,
  updateJob,
  deleteJob,
  createTask,
  updateTask,
  deleteTask,
};
