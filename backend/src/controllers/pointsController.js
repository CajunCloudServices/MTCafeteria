const pointsService = require('../services/pointsService');

async function listAssignableUsers(req, res) {
  try {
    const users = await pointsService.listAssignableUsers({
      requesterRole: req.user.role,
      requesterUserId: req.user.sub,
    });
    return res.json(users);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res
        .status(403)
        .json({ message: 'Only leadership roles can submit points.' });
    }
    throw error;
  }
}

async function createAssignment(req, res) {
  const {
    assignedToUserId,
    pointsDelta,
    assignmentDate,
    reason,
    assignmentDescription,
  } = req.body;

  if (!assignedToUserId || !pointsDelta || !assignmentDate || !reason || !assignmentDescription) {
    return res.status(400).json({
      message:
        'assignedToUserId, pointsDelta, assignmentDate, reason, and assignmentDescription are required.',
    });
  }

  if (!Number.isInteger(Number(pointsDelta)) || Number(pointsDelta) <= 0) {
    return res.status(400).json({ message: 'pointsDelta must be a positive integer.' });
  }

  try {
    const assignment = await pointsService.createPointAssignment({
      requesterRole: req.user.role,
      requesterUserId: req.user.sub,
      assignedToUserId: Number(assignedToUserId),
      pointsDelta: Number(pointsDelta),
      assignmentDate,
      reason: String(reason).trim(),
      assignmentDescription: String(assignmentDescription).trim(),
    });

    return res.status(201).json(assignment);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res
        .status(403)
        .json({ message: 'Only leadership roles can submit points.' });
    }
    if (error.message === 'NotFound') {
      return res.status(404).json({ message: 'User not found for assignment.' });
    }
    throw error;
  }
}

async function listInbox(req, res) {
  const assignments = await pointsService.listPendingAssignmentsForUser(req.user.sub);
  return res.json(assignments);
}

async function listSent(req, res) {
  try {
    const assignments = await pointsService.listAssignmentsSubmittedByUser({
      requesterRole: req.user.role,
      requesterUserId: req.user.sub,
    });
    return res.json(assignments);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res
        .status(403)
        .json({ message: 'Only leadership roles can view submitted point requests.' });
    }
    throw error;
  }
}

async function listManagerApprovalQueue(req, res) {
  try {
    const assignments = await pointsService.listManagerApprovalQueue({
      requesterRole: req.user.role,
    });
    return res.json(assignments);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only student managers can view approval queue.' });
    }
    throw error;
  }
}

async function approveAssignment(req, res) {
  const assignmentId = Number(req.params.id);

  try {
    const assignment = await pointsService.approvePointAssignmentByManager({
      assignmentId,
      managerUserId: req.user.sub,
      requesterRole: req.user.role,
    });
    return res.json(assignment);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only student managers can approve point requests.' });
    }
    if (error.message === 'NotFound') {
      return res.status(404).json({ message: 'Point assignment not found.' });
    }
    if (error.message === 'Conflict') {
      return res.status(409).json({ message: 'Point assignment cannot be approved in its current state.' });
    }
    throw error;
  }
}

async function acceptAssignment(req, res) {
  const assignmentId = Number(req.params.id);
  const { initials } = req.body;

  if (!initials || String(initials).trim().length < 2) {
    return res.status(400).json({ message: 'Initials are required.' });
  }

  try {
    const result = await pointsService.acceptPointAssignment({
      assignmentId,
      userId: req.user.sub,
      initials: String(initials).trim().toUpperCase(),
    });

    return res.json(result);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'You can only accept points assigned to you.' });
    }
    if (error.message === 'NotFound') {
      return res.status(404).json({ message: 'Point assignment not found.' });
    }
    if (error.message === 'Conflict') {
      return res.status(409).json({ message: 'Point assignment was already accepted.' });
    }
    if (error.message === 'ApprovalRequired') {
      return res.status(409).json({ message: 'This point assignment is still pending manager approval.' });
    }
    throw error;
  }
}

module.exports = {
  listAssignableUsers,
  createAssignment,
  listInbox,
  listSent,
  listManagerApprovalQueue,
  approveAssignment,
  acceptAssignment,
};
