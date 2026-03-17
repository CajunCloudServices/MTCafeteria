const env = require('../config/env');
const { pool } = require('../db/pool');
const mockData = require('../db/mockData');
const { Roles } = require('../config/roles');

const PointSubmitRoles = [
  Roles.STUDENT_MANAGER,
  Roles.SUPERVISOR,
  Roles.LEAD_TRAINER,
  Roles.DISHROOM_LEAD_TRAINER,
];

function assertManagerRole(role) {
  if (role !== Roles.STUDENT_MANAGER) {
    throw new Error('Unauthorized');
  }
}

function assertCanSubmitRole(role) {
  if (!PointSubmitRoles.includes(role)) {
    throw new Error('Unauthorized');
  }
}

function normalizeAssignment(row) {
  return {
    id: row.id,
    assignedToUserId: row.assigned_to_user_id ?? row.assignedToUserId,
    assignedToEmail: row.assigned_to_email ?? row.assignedToEmail,
    assignedByUserId: row.assigned_by_user_id ?? row.assignedByUserId,
    assignedByEmail: row.assigned_by_email ?? row.assignedByEmail,
    pointsDelta: row.points_delta ?? row.pointsDelta,
    assignmentDate: row.assignment_date ?? row.assignmentDate,
    reason: row.reason,
    assignmentDescription: row.assignment_description ?? row.assignmentDescription ?? '',
    status: row.status,
    requiresManagerApproval:
      row.requires_manager_approval ?? row.requiresManagerApproval ?? false,
    managerApprovedByUserId:
      row.manager_approved_by_user_id ?? row.managerApprovedByUserId,
    managerApprovedByEmail: row.manager_approved_by_email ?? row.managerApprovedByEmail,
    managerApprovedAt: row.manager_approved_at ?? row.managerApprovedAt,
    employeeInitials: row.employee_initials ?? row.employeeInitials,
    employeeConfirmedAt: row.employee_confirmed_at ?? row.employeeConfirmedAt,
    managerNotifiedAt: row.manager_notified_at ?? row.managerNotifiedAt,
    createdAt: row.created_at ?? row.createdAt,
  };
}

async function listAssignableUsers({ requesterRole, requesterUserId }) {
  assertCanSubmitRole(requesterRole);

  if (env.useMockData) {
    return mockData.users
      .filter((u) => u.id !== requesterUserId)
      .map((u) => {
        const role = mockData.roles.find((r) => r.id === u.roleId)?.name || Roles.EMPLOYEE;
        return { id: u.id, email: u.email, role, points: u.points || 0 };
      });
  }

  const { rows } = await pool.query(
    `
      SELECT u.id, u.email, r.name AS role, COALESCE(p.points, 0) AS points
      FROM users u
      JOIN roles r ON r.id = u.role_id
      LEFT JOIN points p ON p.user_id = u.id
      WHERE u.id <> $1
      ORDER BY u.email ASC;
    `,
    [requesterUserId]
  );

  return rows;
}

async function createPointAssignment({
  requesterRole,
  requesterUserId,
  assignedToUserId,
  pointsDelta,
  assignmentDate,
  reason,
  assignmentDescription,
}) {
  assertCanSubmitRole(requesterRole);

  const requiresManagerApproval = requesterRole !== Roles.STUDENT_MANAGER;

  if (env.useMockData) {
    const assignedUser = mockData.users.find((u) => u.id === assignedToUserId);
    const submitter = mockData.users.find((u) => u.id === requesterUserId);
    if (!assignedUser || !submitter) {
      throw new Error('NotFound');
    }

    const id = Math.max(0, ...mockData.pointAssignments.map((a) => a.id)) + 1;
    const assignment = {
      id,
      assignedToUserId,
      assignedToEmail: assignedUser.email,
      assignedByUserId: requesterUserId,
      assignedByEmail: submitter.email,
      pointsDelta,
      assignmentDate,
      reason,
      assignmentDescription,
      status: 'Pending',
      requiresManagerApproval,
      managerApprovedByUserId: requiresManagerApproval ? null : requesterUserId,
      managerApprovedByEmail: requiresManagerApproval ? null : submitter.email,
      managerApprovedAt: requiresManagerApproval ? null : new Date().toISOString(),
      employeeInitials: null,
      employeeConfirmedAt: null,
      managerNotifiedAt: null,
      createdAt: new Date().toISOString(),
    };
    mockData.pointAssignments.push(assignment);
    return assignment;
  }

  const { rows } = await pool.query(
    `
      INSERT INTO point_assignments (
        assigned_to_user_id,
        assigned_by_user_id,
        points_delta,
        assignment_date,
        reason,
        assignment_description,
        status,
        requires_manager_approval,
        manager_approved_by_user_id,
        manager_approved_at
      )
      VALUES ($1, $2, $3, $4, $5, $6, 'Pending', $7, $8, $9)
      RETURNING id;
    `,
    [
      assignedToUserId,
      requesterUserId,
      pointsDelta,
      assignmentDate,
      reason,
      assignmentDescription,
      requiresManagerApproval,
      requiresManagerApproval ? null : requesterUserId,
      requiresManagerApproval ? null : new Date().toISOString(),
    ]
  );

  const assignmentId = rows[0]?.id;
  const loaded = await loadAssignmentById(assignmentId);
  if (!loaded) {
    throw new Error('NotFound');
  }
  return loaded;
}

async function listPendingAssignmentsForUser(userId) {
  if (env.useMockData) {
    return mockData.pointAssignments
      .filter(
        (a) =>
          a.assignedToUserId === userId &&
          a.status === 'Pending' &&
          (!a.requiresManagerApproval || !!a.managerApprovedAt)
      )
      .sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
  }

  const { rows } = await pool.query(
    `
      SELECT
        pa.id,
        pa.assigned_to_user_id,
        ua.email AS assigned_to_email,
        pa.assigned_by_user_id,
        ub.email AS assigned_by_email,
        pa.points_delta,
        pa.assignment_date,
        pa.reason,
        pa.assignment_description,
        pa.status,
        pa.requires_manager_approval,
        pa.manager_approved_by_user_id,
        um.email AS manager_approved_by_email,
        pa.manager_approved_at,
        pa.employee_initials,
        pa.employee_confirmed_at,
        pa.manager_notified_at,
        pa.created_at
      FROM point_assignments pa
      JOIN users ua ON ua.id = pa.assigned_to_user_id
      JOIN users ub ON ub.id = pa.assigned_by_user_id
      LEFT JOIN users um ON um.id = pa.manager_approved_by_user_id
      WHERE pa.assigned_to_user_id = $1
        AND pa.status = 'Pending'
        AND (
          pa.requires_manager_approval = FALSE
          OR pa.manager_approved_at IS NOT NULL
        )
      ORDER BY pa.created_at DESC;
    `,
    [userId]
  );

  return rows.map(normalizeAssignment);
}

async function listAssignmentsSubmittedByUser({ requesterRole, requesterUserId }) {
  assertCanSubmitRole(requesterRole);

  if (env.useMockData) {
    return mockData.pointAssignments
      .filter((a) => a.assignedByUserId === requesterUserId)
      .sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
  }

  const { rows } = await pool.query(
    `
      SELECT
        pa.id,
        pa.assigned_to_user_id,
        ua.email AS assigned_to_email,
        pa.assigned_by_user_id,
        ub.email AS assigned_by_email,
        pa.points_delta,
        pa.assignment_date,
        pa.reason,
        pa.assignment_description,
        pa.status,
        pa.requires_manager_approval,
        pa.manager_approved_by_user_id,
        um.email AS manager_approved_by_email,
        pa.manager_approved_at,
        pa.employee_initials,
        pa.employee_confirmed_at,
        pa.manager_notified_at,
        pa.created_at
      FROM point_assignments pa
      JOIN users ua ON ua.id = pa.assigned_to_user_id
      JOIN users ub ON ub.id = pa.assigned_by_user_id
      LEFT JOIN users um ON um.id = pa.manager_approved_by_user_id
      WHERE pa.assigned_by_user_id = $1
      ORDER BY pa.created_at DESC;
    `,
    [requesterUserId]
  );

  return rows.map(normalizeAssignment);
}

async function listManagerApprovalQueue({ requesterRole }) {
  assertManagerRole(requesterRole);

  if (env.useMockData) {
    return mockData.pointAssignments
      .filter(
        (a) =>
          a.status === 'Pending' &&
          a.requiresManagerApproval &&
          !a.managerApprovedAt
      )
      .sort((a, b) => (a.createdAt < b.createdAt ? 1 : -1));
  }

  const { rows } = await pool.query(
    `
      SELECT
        pa.id,
        pa.assigned_to_user_id,
        ua.email AS assigned_to_email,
        pa.assigned_by_user_id,
        ub.email AS assigned_by_email,
        pa.points_delta,
        pa.assignment_date,
        pa.reason,
        pa.assignment_description,
        pa.status,
        pa.requires_manager_approval,
        pa.manager_approved_by_user_id,
        um.email AS manager_approved_by_email,
        pa.manager_approved_at,
        pa.employee_initials,
        pa.employee_confirmed_at,
        pa.manager_notified_at,
        pa.created_at
      FROM point_assignments pa
      JOIN users ua ON ua.id = pa.assigned_to_user_id
      JOIN users ub ON ub.id = pa.assigned_by_user_id
      LEFT JOIN users um ON um.id = pa.manager_approved_by_user_id
      WHERE pa.status = 'Pending'
        AND pa.requires_manager_approval = TRUE
        AND pa.manager_approved_at IS NULL
      ORDER BY pa.created_at DESC;
    `
  );

  return rows.map(normalizeAssignment);
}

async function approvePointAssignmentByManager({ assignmentId, managerUserId, requesterRole }) {
  assertManagerRole(requesterRole);

  if (env.useMockData) {
    const assignment = mockData.pointAssignments.find((a) => a.id === assignmentId);
    if (!assignment) throw new Error('NotFound');
    if (assignment.status !== 'Pending') throw new Error('Conflict');
    if (!assignment.requiresManagerApproval || assignment.managerApprovedAt) {
      throw new Error('Conflict');
    }

    assignment.managerApprovedByUserId = managerUserId;
    assignment.managerApprovedByEmail = mockData.users.find((u) => u.id === managerUserId)?.email || null;
    assignment.managerApprovedAt = new Date().toISOString();
    return assignment;
  }

  const { rows } = await pool.query(
    `
      UPDATE point_assignments
      SET
        manager_approved_by_user_id = $2,
        manager_approved_at = NOW()
      WHERE id = $1
        AND status = 'Pending'
        AND requires_manager_approval = TRUE
        AND manager_approved_at IS NULL
      RETURNING id;
    `,
    [assignmentId, managerUserId]
  );

  if (!rows[0]) {
    const existing = await loadAssignmentById(assignmentId);
    if (!existing) throw new Error('NotFound');
    throw new Error('Conflict');
  }

  const loaded = await loadAssignmentById(assignmentId);
  if (!loaded) throw new Error('NotFound');
  return loaded;
}

async function acceptPointAssignment({ assignmentId, userId, initials }) {
  if (env.useMockData) {
    const assignment = mockData.pointAssignments.find((a) => a.id === assignmentId);
    if (!assignment) throw new Error('NotFound');
    if (assignment.assignedToUserId !== userId) throw new Error('Unauthorized');
    if (assignment.status !== 'Pending') throw new Error('Conflict');
    if (assignment.requiresManagerApproval && !assignment.managerApprovedAt) {
      throw new Error('ApprovalRequired');
    }

    const targetUser = mockData.users.find((u) => u.id === userId);
    if (!targetUser) throw new Error('NotFound');

    targetUser.points = (targetUser.points || 0) + assignment.pointsDelta;
    assignment.status = 'Accepted';
    assignment.employeeInitials = initials;
    assignment.employeeConfirmedAt = new Date().toISOString();
    assignment.managerNotifiedAt = assignment.employeeConfirmedAt;

    return {
      assignment,
      updatedPoints: targetUser.points,
    };
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    const { rows } = await client.query(
      `
        SELECT id, assigned_to_user_id, points_delta, status, requires_manager_approval, manager_approved_at
        FROM point_assignments
        WHERE id = $1
        FOR UPDATE;
      `,
      [assignmentId]
    );

    const assignment = rows[0];
    if (!assignment) {
      throw new Error('NotFound');
    }
    if (assignment.assigned_to_user_id !== userId) {
      throw new Error('Unauthorized');
    }
    if (assignment.status !== 'Pending') {
      throw new Error('Conflict');
    }
    if (assignment.requires_manager_approval && !assignment.manager_approved_at) {
      throw new Error('ApprovalRequired');
    }

    await client.query(
      `
        INSERT INTO points (user_id, points)
        VALUES ($1, $2)
        ON CONFLICT (user_id)
        DO UPDATE SET points = points.points + EXCLUDED.points;
      `,
      [userId, assignment.points_delta]
    );

    await client.query(
      `
        UPDATE point_assignments
        SET
          status = 'Accepted',
          employee_initials = $2,
          employee_confirmed_at = NOW(),
          manager_notified_at = NOW()
        WHERE id = $1;
      `,
      [assignmentId, initials]
    );

    const pointsResult = await client.query('SELECT points FROM points WHERE user_id = $1;', [userId]);

    await client.query('COMMIT');

    const loaded = await loadAssignmentById(assignmentId);
    return {
      assignment: loaded,
      updatedPoints: pointsResult.rows[0]?.points || 0,
    };
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

async function loadAssignmentById(assignmentId) {
  if (env.useMockData) {
    return mockData.pointAssignments.find((a) => a.id === assignmentId) || null;
  }

  const { rows } = await pool.query(
    `
      SELECT
        pa.id,
        pa.assigned_to_user_id,
        ua.email AS assigned_to_email,
        pa.assigned_by_user_id,
        ub.email AS assigned_by_email,
        pa.points_delta,
        pa.assignment_date,
        pa.reason,
        pa.assignment_description,
        pa.status,
        pa.requires_manager_approval,
        pa.manager_approved_by_user_id,
        um.email AS manager_approved_by_email,
        pa.manager_approved_at,
        pa.employee_initials,
        pa.employee_confirmed_at,
        pa.manager_notified_at,
        pa.created_at
      FROM point_assignments pa
      JOIN users ua ON ua.id = pa.assigned_to_user_id
      JOIN users ub ON ub.id = pa.assigned_by_user_id
      LEFT JOIN users um ON um.id = pa.manager_approved_by_user_id
      WHERE pa.id = $1
      LIMIT 1;
    `,
    [assignmentId]
  );

  return rows[0] ? normalizeAssignment(rows[0]) : null;
}

module.exports = {
  listAssignableUsers,
  createPointAssignment,
  listPendingAssignmentsForUser,
  listAssignmentsSubmittedByUser,
  listManagerApprovalQueue,
  approvePointAssignmentByManager,
  acceptPointAssignment,
};
