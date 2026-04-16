const service = require('../services/taskAdminService');

function handleError(res, error) {
  if (error instanceof service.ValidationError) {
    res.status(error.statusCode).json({ message: error.message });
    return true;
  }
  if (error instanceof service.NotFoundError) {
    res.status(error.statusCode).json({ message: error.message });
    return true;
  }
  return false;
}

async function getBoard(_req, res, next) {
  try {
    const board = await service.listBoard();
    res.set('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.set('Pragma', 'no-cache');
    res.set('Expires', '0');
    res.set('Surrogate-Control', 'no-store');
    res.json(board);
  } catch (error) {
    next(error);
  }
}

async function createJob(req, res, next) {
  try {
    const job = await service.createJob(req.body || {});
    res.status(201).json(job);
  } catch (error) {
    if (!handleError(res, error)) next(error);
  }
}

async function updateJob(req, res, next) {
  try {
    const job = await service.updateJob(req.params.jobId, req.body || {});
    res.json(job);
  } catch (error) {
    if (!handleError(res, error)) next(error);
  }
}

async function deleteJob(req, res, next) {
  try {
    await service.deleteJob(req.params.jobId);
    res.status(204).send();
  } catch (error) {
    if (!handleError(res, error)) next(error);
  }
}

async function createTask(req, res, next) {
  try {
    const task = await service.createTask(req.params.jobId, req.body || {});
    res.status(201).json(task);
  } catch (error) {
    if (!handleError(res, error)) next(error);
  }
}

async function updateTask(req, res, next) {
  try {
    const task = await service.updateTask(req.params.taskId, req.body || {});
    res.json(task);
  } catch (error) {
    if (!handleError(res, error)) next(error);
  }
}

async function deleteTask(req, res, next) {
  try {
    await service.deleteTask(req.params.taskId);
    res.status(204).send();
  } catch (error) {
    if (!handleError(res, error)) next(error);
  }
}

module.exports = {
  getBoard,
  createJob,
  updateJob,
  deleteJob,
  createTask,
  updateTask,
  deleteTask,
};
