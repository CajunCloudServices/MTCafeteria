const taskBoardService = require('../services/taskBoardService');

async function getTaskBoard(req, res, next) {
  try {
    const board = await taskBoardService.getTaskBoardForUser(req.user, {
      meal: req.query.meal,
      jobId: req.query.jobId,
      preferredJobName: req.query.preferredJobName,
    });
    return res.json(board);
  } catch (error) {
    return next(error);
  }
}

async function toggleTaskCompletion(req, res, next) {
  try {
    const { taskId } = req.params;
    const { completed } = req.body;
    await taskBoardService.setTaskCompletion(req.user, { taskId, completed });
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}

async function resetTaskFlow(req, res, next) {
  try {
    const { meal, jobId } = req.body;
    await taskBoardService.resetTaskFlowForUser(req.user, { meal, jobId });
    return res.status(204).send();
  } catch (error) {
    return next(error);
  }
}

async function getSupervisorBoard(req, res, next) {
  try {
    const board = await taskBoardService.getSupervisorBoard(req.user, {
      meal: req.query.meal,
    });
    return res.json(board);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors and student managers can access this board.' });
    }
    return next(error);
  }
}

async function toggleSupervisorJobCheck(req, res, next) {
  try {
    const { jobId } = req.params;
    const { meal, checked } = req.body;
    await taskBoardService.setSupervisorJobCheck(req.user, { meal, jobId, checked });
    return res.status(204).send();
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors and student managers can access this board.' });
    }
    return next(error);
  }
}

async function getSupervisorJobTasks(req, res, next) {
  try {
    const { jobId } = req.params;
    const board = await taskBoardService.getSupervisorJobTasks(req.user, {
      meal: req.query.meal,
      jobId,
    });
    return res.json(board);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors and student managers can access this board.' });
    }
    return next(error);
  }
}

async function toggleSupervisorTaskCheck(req, res, next) {
  try {
    const { jobId, taskId } = req.params;
    const { meal, checked } = req.body;
    await taskBoardService.setSupervisorTaskCheck(req.user, {
      meal,
      jobId,
      taskId,
      checked,
    });
    return res.status(204).send();
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors and student managers can access this board.' });
    }
    return next(error);
  }
}

async function resetSupervisorBoard(req, res, next) {
  try {
    const { meal } = req.body;
    await taskBoardService.resetSupervisorBoard(req.user, { meal });
    return res.status(204).send();
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors and student managers can access this board.' });
    }
    return next(error);
  }
}

async function getTrainerBoard(req, res, next) {
  try {
    const board = await taskBoardService.getTrainerBoard(req.user, {
      meal: req.query.meal,
      jobIds: req.query.jobIds,
    });
    return res.json(board);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only lead trainers and admins can access this board.' });
    }
    return next(error);
  }
}

async function toggleTrainerTraineeTaskCompletion(req, res, next) {
  try {
    const { traineeUserId, taskId } = req.params;
    const { completed } = req.body;
    await taskBoardService.setTrainerTraineeTaskCompletion(req.user, {
      traineeUserId,
      taskId,
      completed,
    });
    return res.status(204).send();
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only lead trainers and admins can access this board.' });
    }
    return next(error);
  }
}

module.exports = {
  getTaskBoard,
  toggleTaskCompletion,
  resetTaskFlow,
  getSupervisorBoard,
  getSupervisorJobTasks,
  toggleSupervisorJobCheck,
  toggleSupervisorTaskCheck,
  resetSupervisorBoard,
  getTrainerBoard,
  toggleTrainerTraineeTaskCompletion,
};
