const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');
const { Roles } = require('../config/roles');

const MEALS = ['Breakfast', 'Lunch', 'Dinner'];

function getMealFromInput(mealInput) {
  const meal = mealInput && MEALS.includes(mealInput) ? mealInput : 'Breakfast';
  return meal;
}

function canAccessSupervisorBoard(role) {
  return role === Roles.SUPERVISOR || role === Roles.STUDENT_MANAGER;
}

function canAccessTrainerBoard(role) {
  return role === Roles.LEAD_TRAINER || role === Roles.SUPERVISOR || role === Roles.STUDENT_MANAGER;
}

function getShiftForMeal(meal) {
  return mockData.shifts.find((s) => s.mealType === meal);
}

function getJobsForMeal(meal) {
  const shift = getShiftForMeal(meal);
  if (!shift) return [];
  return mockData.jobs.filter((j) => j.shiftId === shift.id);
}

function getTaskProgressForUser(userId, taskId) {
  return mockData.taskProgress.find((p) => p.userId === userId && p.taskId === taskId);
}

function parseJobIdsInput(jobIdsInput) {
  if (!jobIdsInput) return [];
  const raw = Array.isArray(jobIdsInput) ? jobIdsInput.join(',') : String(jobIdsInput);
  return raw
    .split(',')
    .map((v) => Number(v.trim()))
    .filter((v) => Number.isInteger(v) && v > 0);
}
async function getTaskBoardForUser(requestUser, { meal, jobId, preferredJobName }) {
  const selectedMeal = getMealFromInput(meal);

  if (env.useMockData) {
    const uniqueJobsByName = new Map();
    for (const job of mockData.jobs) {
      if (!uniqueJobsByName.has(job.name)) {
        uniqueJobsByName.set(job.name, []);
      }
      uniqueJobsByName.get(job.name).push(job);
    }

    const jobs = [...uniqueJobsByName.entries()]
      .map(([jobName, variants]) => {
        const canonical = [...variants].sort((a, b) => a.id - b.id)[0];
        return { id: canonical.id, name: jobName };
      })
      .sort((a, b) => a.name.localeCompare(b.name));

    const preferredJob = preferredJobName
      ? jobs.find((j) => j.name === preferredJobName)
      : null;
    const selectedJobId = Number(jobId || preferredJob?.id || jobs[0]?.id || 0);
    const selectedJob = jobs.find((j) => j.id === selectedJobId) || jobs[0];
    const selectedJobName = selectedJob?.name;
    const taskJob = selectedJobName
      ? (mockData.jobs.find((j) => {
          const shift = mockData.shifts.find((s) => s.id === j.shiftId);
          return j.name === selectedJobName && shift?.mealType === selectedMeal;
        }) || mockData.jobs.find((j) => j.name === selectedJobName))
      : null;

    const tasks = taskJob
      ? mockData.tasks
          .filter((t) => t.jobId === taskJob.id)
          .map((t) => {
            const progress = getTaskProgressForUser(Number(requestUser.sub), t.id);
            return {
              taskId: t.id,
              phase: t.phase,
              description: t.description,
              requiresCheckoff: t.requiresCheckoff !== false,
              completed: progress?.completed || false,
            };
          })
      : [];

    return {
      meals: MEALS,
      selectedMeal,
      jobs: jobs.map((j) => ({ id: j.id, name: j.name })),
      selectedJobId: selectedJob?.id || 0,
      tasks,
    };
  }

  const jobsQuery = `
    SELECT DISTINCT ON (j.name)
      j.id,
      j.name
    FROM jobs j
    ORDER BY
      j.name,
      j.id;
  `;
  const jobsResult = await pool.query(jobsQuery);
  const jobs = jobsResult.rows;
  const preferredJob = preferredJobName
    ? jobs.find((j) => j.name === preferredJobName)
    : null;
  const selectedJobId = Number(jobId || preferredJob?.id || jobs[0]?.id || 0);
  const selectedJob = jobs.find((j) => j.id === selectedJobId) || jobs[0];
  const selectedJobName = selectedJob?.name;

  let taskJobId = null;
  if (selectedJobName) {
    const preferredTaskJob = await pool.query(
      `
        SELECT j.id
        FROM jobs j
        JOIN shifts s ON s.id = j.shift_id
        WHERE j.name = $1 AND s.meal_type = $2
        ORDER BY j.id
        LIMIT 1;
      `,
      [selectedJobName, selectedMeal]
    );

    if (preferredTaskJob.rowCount > 0) {
      taskJobId = preferredTaskJob.rows[0].id;
    } else {
      const fallbackTaskJob = await pool.query(
        `
          SELECT j.id
          FROM jobs j
          WHERE j.name = $1
          ORDER BY j.id
          LIMIT 1;
        `,
        [selectedJobName]
      );
      taskJobId = fallbackTaskJob.rowCount > 0 ? fallbackTaskJob.rows[0].id : null;
    }
  }

  const tasksQuery = `
    SELECT
      t.id AS "taskId",
      t.phase,
      t.description,
      CASE WHEN t.phase = 'During Shift' THEN false ELSE true END AS "requiresCheckoff",
      COALESCE(tp.completed, false) AS completed
    FROM tasks t
    LEFT JOIN task_progress tp ON tp.task_id = t.id AND tp.user_id = $2
    WHERE t.job_id = $1
    ORDER BY t.id;
  `;
  const tasksResult = taskJobId
    ? await pool.query(tasksQuery, [taskJobId, Number(requestUser.sub)])
    : { rows: [] };

  return {
    meals: MEALS,
    selectedMeal,
    jobs,
    selectedJobId,
    tasks: tasksResult.rows,
  };
}

async function setTaskCompletion(requestUser, { taskId, completed }) {
  const userId = Number(requestUser.sub);

  if (env.useMockData) {
    const task = mockData.tasks.find((t) => t.id === Number(taskId));
    if (!task || task.requiresCheckoff === false || task.phase === 'During Shift') {
      return;
    }

    const existing = mockData.taskProgress.find((p) => p.userId === userId && p.taskId === Number(taskId));
    if (existing) {
      existing.completed = Boolean(completed);
    } else {
      mockData.taskProgress.push({ userId, taskId: Number(taskId), completed: Boolean(completed) });
    }
    return;
  }

  const query = `
    INSERT INTO task_progress (user_id, task_id, completed, supervisor_checked)
    VALUES ($1, $2, $3, false)
    ON CONFLICT (user_id, task_id)
    DO UPDATE SET completed = EXCLUDED.completed;
  `;
  const allowedTask = await pool.query('SELECT id FROM tasks WHERE id = $1 AND phase <> $2 LIMIT 1;', [
    Number(taskId),
    'During Shift',
  ]);
  if (allowedTask.rowCount === 0) {
    return;
  }

  await pool.query(query, [userId, Number(taskId), Boolean(completed)]);
}

async function resetTaskFlowForUser(requestUser, { meal, jobId }) {
  const userId = Number(requestUser.sub);
  const selectedMeal = getMealFromInput(meal);
  const targetJobId = Number(jobId);
  if (!Number.isInteger(targetJobId) || targetJobId <= 0) {
    return;
  }

  if (env.useMockData) {
    const selectedJob = mockData.jobs.find((j) => j.id === targetJobId);
    if (!selectedJob) return;

    const selectedJobName = selectedJob.name;
    const mealShift = getShiftForMeal(selectedMeal);
    const scopedJob = mockData.jobs.find(
      (j) => j.name === selectedJobName && j.shiftId === mealShift?.id
    );
    const effectiveJob = scopedJob || selectedJob;

    const resettableTaskIds = new Set(
      mockData.tasks
        .filter(
          (t) =>
            t.jobId === effectiveJob.id &&
            t.phase !== 'During Shift' &&
            t.requiresCheckoff !== false
        )
        .map((t) => t.id)
    );
    if (resettableTaskIds.size == 0) return;

    const retained = mockData.taskProgress.filter(
      (p) => !(p.userId === userId && resettableTaskIds.has(p.taskId))
    );
    mockData.taskProgress.splice(0, mockData.taskProgress.length, ...retained);
    return;
  }

  const selectedJobResult = await pool.query(
    'SELECT id, name FROM jobs WHERE id = $1 LIMIT 1;',
    [targetJobId]
  );
  if (selectedJobResult.rowCount === 0) return;

  const selectedJobName = selectedJobResult.rows[0].name;
  const scopedJobResult = await pool.query(
    `
      SELECT j.id
      FROM jobs j
      JOIN shifts s ON s.id = j.shift_id
      WHERE j.name = $1 AND s.meal_type = $2
      ORDER BY j.id
      LIMIT 1;
    `,
    [selectedJobName, selectedMeal]
  );
  const effectiveJobId =
    scopedJobResult.rowCount > 0
      ? Number(scopedJobResult.rows[0].id)
      : targetJobId;

  await pool.query(
    `
      DELETE FROM task_progress
      WHERE user_id = $1
        AND task_id IN (
          SELECT t.id
          FROM tasks t
          WHERE t.job_id = $2
            AND t.phase <> 'During Shift'
        );
    `,
    [userId, effectiveJobId]
  );
}

async function getSupervisorBoard(requestUser, { meal }) {
  if (!canAccessSupervisorBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  const selectedMeal = getMealFromInput(meal);

  if (env.useMockData) {
    const uniqueJobsByName = new Map();
    for (const job of mockData.jobs) {
      if (!uniqueJobsByName.has(job.name)) {
        uniqueJobsByName.set(job.name, []);
      }
      uniqueJobsByName.get(job.name).push(job);
    }

    const jobs = [...uniqueJobsByName.entries()]
      .map(([jobName, variants]) => {
        const preferred = variants.find((job) => {
          const shift = mockData.shifts.find((s) => s.id === job.shiftId);
          return shift?.mealType === selectedMeal;
        });
        const chosenJob = preferred || variants[0];

        const jobTasks = mockData.tasks.filter(
          (t) => t.jobId === chosenJob.id && t.phase === 'Cleanup'
        );

        const taskChecks = jobTasks.filter((task) =>
          mockData.supervisorTaskChecks.some(
            (c) =>
              c.mealType === selectedMeal &&
              c.jobId === chosenJob.id &&
              c.taskId === task.id &&
              c.checked
          )
        );
        const check = mockData.supervisorJobChecks.find(
          (c) => c.mealType === selectedMeal && c.jobId === chosenJob.id
        );

        return {
          jobId: chosenJob.id,
          jobName,
          checked: check?.checked || false,
          checkedCount: taskChecks.length,
          totalCount: jobTasks.length,
        };
      })
      .sort((a, b) => a.jobName.localeCompare(b.jobName));

    return {
      meals: MEALS,
      selectedMeal,
      jobs,
    };
  }

  const query = `
    WITH chosen_jobs AS (
      SELECT DISTINCT ON (j.name)
        j.id AS job_id,
        j.name AS job_name
      FROM jobs j
      JOIN shifts s ON s.id = j.shift_id
      ORDER BY
        j.name,
        CASE WHEN s.meal_type = $1 THEN 0 ELSE 1 END,
        j.id
    )
    SELECT
      cj.job_id AS "jobId",
      cj.job_name AS "jobName",
      COALESCE(sjc.checked, false) AS checked,
      COALESCE(stats.checked_count, 0) AS "checkedCount",
      COALESCE(stats.total_count, 0) AS "totalCount"
    FROM chosen_jobs cj
    LEFT JOIN supervisor_job_checks sjc ON sjc.job_id = cj.job_id AND sjc.meal_type = $1
    LEFT JOIN (
      SELECT
        t.job_id,
        COUNT(*) AS total_count,
        COUNT(*) FILTER (WHERE COALESCE(stc.checked, false)) AS checked_count
      FROM tasks t
      LEFT JOIN supervisor_task_checks stc
        ON stc.task_id = t.id AND stc.job_id = t.job_id AND stc.meal_type = $1
      WHERE t.phase = 'Cleanup'
      GROUP BY t.job_id
    ) stats ON stats.job_id = cj.job_id
    ORDER BY cj.job_name;
  `;

  const result = await pool.query(query, [selectedMeal]);
  return {
    meals: MEALS,
    selectedMeal,
    jobs: result.rows,
  };
}

async function setSupervisorJobCheck(requestUser, { meal, jobId, checked }) {
  if (!canAccessSupervisorBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  const selectedMeal = getMealFromInput(meal);

  if (env.useMockData) {
    const existing = mockData.supervisorJobChecks.find((c) => c.mealType === selectedMeal && c.jobId === Number(jobId));
    if (existing) {
      existing.checked = Boolean(checked);
    } else {
      mockData.supervisorJobChecks.push({ mealType: selectedMeal, jobId: Number(jobId), checked: Boolean(checked) });
    }
    return;
  }

  const query = `
    INSERT INTO supervisor_job_checks (meal_type, job_id, checked)
    VALUES ($1, $2, $3)
    ON CONFLICT (meal_type, job_id)
    DO UPDATE SET checked = EXCLUDED.checked;
  `;
  await pool.query(query, [selectedMeal, Number(jobId), Boolean(checked)]);
}

async function resetSupervisorBoard(requestUser, { meal }) {
  if (!canAccessSupervisorBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  const selectedMeal = getMealFromInput(meal);

  if (env.useMockData) {
    const retained = mockData.supervisorJobChecks.filter((c) => c.mealType !== selectedMeal);
    mockData.supervisorJobChecks.splice(0, mockData.supervisorJobChecks.length, ...retained);
    const taskRetained = mockData.supervisorTaskChecks.filter((c) => c.mealType !== selectedMeal);
    mockData.supervisorTaskChecks.splice(0, mockData.supervisorTaskChecks.length, ...taskRetained);
    return;
  }

  await pool.query('DELETE FROM supervisor_job_checks WHERE meal_type = $1;', [selectedMeal]);
  await pool.query('DELETE FROM supervisor_task_checks WHERE meal_type = $1;', [selectedMeal]);
}

async function getSupervisorJobTasks(requestUser, { meal, jobId }) {
  if (!canAccessSupervisorBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  const selectedMeal = getMealFromInput(meal);
  const targetJobId = Number(jobId);

  if (env.useMockData) {
    const job = mockData.jobs.find((j) => j.id === targetJobId);
    const tasks = mockData.tasks
      .filter((t) => t.jobId === targetJobId && t.phase === 'Cleanup')
      .map((t) => {
        const check = mockData.supervisorTaskChecks.find(
          (c) => c.mealType === selectedMeal && c.jobId === targetJobId && c.taskId === t.id
        );
        return {
          taskId: t.id,
          phase: t.phase,
          description: t.description,
          checked: check?.checked || false,
        };
      });

    return {
      meal: selectedMeal,
      jobId: targetJobId,
      jobName: job?.name || 'Unknown Job',
      tasks,
    };
  }

  const jobResult = await pool.query('SELECT id, name FROM jobs WHERE id = $1 LIMIT 1;', [targetJobId]);
  const job = jobResult.rows[0];

  const tasksResult = await pool.query(
    `
      SELECT
        t.id AS "taskId",
        t.phase,
        t.description,
        COALESCE(stc.checked, false) AS checked
      FROM tasks t
      LEFT JOIN supervisor_task_checks stc
        ON stc.meal_type = $1 AND stc.job_id = t.job_id AND stc.task_id = t.id
      WHERE t.job_id = $2 AND t.phase = 'Cleanup'
      ORDER BY t.id;
    `,
    [selectedMeal, targetJobId]
  );

  return {
    meal: selectedMeal,
    jobId: targetJobId,
    jobName: job?.name || 'Unknown Job',
    tasks: tasksResult.rows,
  };
}

async function setSupervisorTaskCheck(requestUser, { meal, jobId, taskId, checked }) {
  if (!canAccessSupervisorBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  const selectedMeal = getMealFromInput(meal);
  const targetJobId = Number(jobId);
  const targetTaskId = Number(taskId);

  if (env.useMockData) {
    const task = mockData.tasks.find((t) => t.id === targetTaskId && t.jobId === targetJobId);
    if (!task || task.phase !== 'Cleanup') {
      return;
    }

    const existing = mockData.supervisorTaskChecks.find(
      (c) => c.mealType === selectedMeal && c.jobId === targetJobId && c.taskId === targetTaskId
    );
    if (existing) {
      existing.checked = Boolean(checked);
    } else {
      mockData.supervisorTaskChecks.push({
        mealType: selectedMeal,
        jobId: targetJobId,
        taskId: targetTaskId,
        checked: Boolean(checked),
      });
    }
    return;
  }

  await pool.query(
    `
      INSERT INTO supervisor_task_checks (meal_type, job_id, task_id, checked)
      SELECT $1, $2, $3, $4
      WHERE EXISTS (
        SELECT 1 FROM tasks t WHERE t.id = $3 AND t.job_id = $2 AND t.phase = 'Cleanup'
      )
      ON CONFLICT (meal_type, job_id, task_id)
      DO UPDATE SET checked = EXCLUDED.checked, updated_at = NOW();
    `,
    [selectedMeal, targetJobId, targetTaskId, Boolean(checked)]
  );
}

async function getTrainerBoard(requestUser, { meal, jobIds }) {
  if (!canAccessTrainerBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  const selectedMeal = getMealFromInput(meal);
  const parsedJobIds = parseJobIdsInput(jobIds);
  if (env.useMockData) {
    const uniqueJobsByName = new Map();
    for (const job of mockData.jobs) {
      if (!uniqueJobsByName.has(job.name)) {
        uniqueJobsByName.set(job.name, []);
      }
      uniqueJobsByName.get(job.name).push(job);
    }

    const jobs = [...uniqueJobsByName.entries()]
      .map(([jobName, variants]) => {
        const chosenJob = [...variants].sort((a, b) => a.id - b.id)[0];
        return { id: chosenJob.id, name: jobName };
      })
      .sort((a, b) => a.name.localeCompare(b.name));

    const trainerId = Number(requestUser.sub);
    let allAssignments = mockData.trainerAssignments.filter(
      (a) => a.trainerUserId === trainerId
    );
    if (allAssignments.length === 0) {
      allAssignments = mockData.trainerAssignments;
    }

    const selectedJobIds = parsedJobIds;
    const selectedNames = new Set(
      jobs.filter((j) => selectedJobIds.includes(j.id)).map((j) => j.name)
    );

    const trainees = allAssignments
      .map((assignment) => {
        if (!selectedNames.has(assignment.jobName)) return null;

        const assignmentShift = mockData.shifts.find(
          (s) => s.mealType === assignment.mealType
        );
        const taskJob = mockData.jobs.find(
          (j) => j.shiftId === assignmentShift?.id && j.name === assignment.jobName
        );
        if (!taskJob) return null;

        const displayJob = jobs.find((j) => j.name === assignment.jobName);
        if (!displayJob) return null;

        const trainee = mockData.users.find((u) => u.id === assignment.traineeUserId);
        if (!trainee) return null;

        const tasks = mockData.tasks
          .filter((t) => t.jobId === taskJob.id)
          .map((t) => {
            const progress = getTaskProgressForUser(assignment.traineeUserId, t.id);
            return {
              taskId: t.id,
              phase: t.phase,
              description: t.description,
              requiresCheckoff: t.requiresCheckoff !== false,
              completed: progress?.completed || false,
            };
          });

        return {
          traineeUserId: trainee.id,
          traineeName: trainee.email,
          jobId: displayJob.id,
          jobName: displayJob.name,
          tasks,
        };
      })
      .filter(Boolean);

    return {
      meals: MEALS,
      selectedMeal,
      jobs,
      selectedJobIds,
      trainees,
    };
  }

  const jobsQuery = `
    SELECT DISTINCT ON (j.name)
      j.id,
      j.name
    FROM jobs j
    ORDER BY
      j.name,
      j.id;
  `;
  const jobsResult = await pool.query(jobsQuery);
  const jobs = jobsResult.rows;
  const selectedNames = new Set(
    jobs.filter((j) => parsedJobIds.includes(j.id)).map((j) => j.name)
  );

  let assignmentsRows = [];
  const scopedAssignmentsResult = await pool.query(
    `
      SELECT ta.trainee_user_id AS "traineeUserId", ta.job_id AS "jobId", u.email AS "traineeName", j.name AS "jobName"
      FROM trainer_assignments ta
      JOIN users u ON u.id = ta.trainee_user_id
      JOIN jobs j ON j.id = ta.job_id
      WHERE ta.trainer_user_id = $1
      ORDER BY ta.trainee_user_id;
    `,
    [Number(requestUser.sub)]
  );
  assignmentsRows = scopedAssignmentsResult.rows;

  if (assignmentsRows.length === 0) {
    const fallbackAssignmentsResult = await pool.query(
      `
        SELECT ta.trainee_user_id AS "traineeUserId", ta.job_id AS "jobId", u.email AS "traineeName", j.name AS "jobName"
        FROM trainer_assignments ta
        JOIN users u ON u.id = ta.trainee_user_id
        JOIN jobs j ON j.id = ta.job_id
        ORDER BY ta.trainee_user_id;
      `
    );
    assignmentsRows = fallbackAssignmentsResult.rows;
  }

  const selectedJobIds = parsedJobIds;

  const trainees = [];
  for (const assignment of assignmentsRows) {
    if (!selectedNames.has(assignment.jobName)) continue;
    const displayJob = jobs.find((j) => j.name === assignment.jobName);
    if (!displayJob) continue;
    const tasksResult = await pool.query(
      `
        SELECT
          t.id AS "taskId",
          t.phase,
          t.description,
          CASE WHEN t.phase = 'During Shift' THEN false ELSE true END AS "requiresCheckoff",
          COALESCE(tp.completed, false) AS completed
        FROM tasks t
        LEFT JOIN task_progress tp ON tp.task_id = t.id AND tp.user_id = $2
        WHERE t.job_id = $1
        ORDER BY t.id;
      `,
      [assignment.jobId, assignment.traineeUserId]
    );

    trainees.push({
      traineeUserId: assignment.traineeUserId,
      traineeName: assignment.traineeName,
      jobId: displayJob.id,
      jobName: assignment.jobName,
      tasks: tasksResult.rows,
    });
  }

  return {
    meals: MEALS,
    selectedMeal,
    jobs,
    selectedJobIds,
    trainees,
  };
}

async function setTrainerTraineeTaskCompletion(requestUser, { traineeUserId, taskId, completed }) {
  if (!canAccessTrainerBoard(requestUser.role)) {
    throw new Error('Unauthorized');
  }

  if (env.useMockData) {
    const task = mockData.tasks.find((t) => t.id === Number(taskId));
    if (!task || task.requiresCheckoff === false || task.phase === 'During Shift') {
      return;
    }

    const existing = mockData.taskProgress.find(
      (p) => p.userId === Number(traineeUserId) && p.taskId === Number(taskId)
    );
    if (existing) {
      existing.completed = Boolean(completed);
    } else {
      mockData.taskProgress.push({
        userId: Number(traineeUserId),
        taskId: Number(taskId),
        completed: Boolean(completed),
      });
    }
    return;
  }

  const allowedTask = await pool.query(
    'SELECT id FROM tasks WHERE id = $1 AND phase <> $2 LIMIT 1;',
    [Number(taskId), 'During Shift']
  );
  if (allowedTask.rowCount === 0) {
    return;
  }

  await pool.query(
    `
      INSERT INTO task_progress (user_id, task_id, completed, supervisor_checked)
      VALUES ($1, $2, $3, false)
      ON CONFLICT (user_id, task_id)
      DO UPDATE SET completed = EXCLUDED.completed;
    `,
    [Number(traineeUserId), Number(taskId), Boolean(completed)]
  );
}

module.exports = {
  getTaskBoardForUser,
  setTaskCompletion,
  resetTaskFlowForUser,
  getSupervisorBoard,
  getSupervisorJobTasks,
  setSupervisorJobCheck,
  setSupervisorTaskCheck,
  resetSupervisorBoard,
  getTrainerBoard,
  setTrainerTraineeTaskCompletion,
};
