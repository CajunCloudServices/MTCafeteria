const express = require('express');
const taskBoardController = require('../controllers/taskBoardController');
const { requireAuth } = require('../middleware/authMiddleware');
const { asyncHandler } = require('../middleware/asyncHandler');

const router = express.Router();

router.get('/task-board', requireAuth, asyncHandler(taskBoardController.getTaskBoard));
router.post('/task-board/tasks/:taskId/completion', requireAuth, asyncHandler(taskBoardController.toggleTaskCompletion));
router.post('/task-board/reset-flow', requireAuth, asyncHandler(taskBoardController.resetTaskFlow));

router.get('/supervisor-board', requireAuth, asyncHandler(taskBoardController.getSupervisorBoard));
router.post('/supervisor-board/jobs/:jobId/check', requireAuth, asyncHandler(taskBoardController.toggleSupervisorJobCheck));
router.get('/supervisor-board/jobs/:jobId/tasks', requireAuth, asyncHandler(taskBoardController.getSupervisorJobTasks));
router.post('/supervisor-board/jobs/:jobId/tasks/:taskId/check', requireAuth, asyncHandler(taskBoardController.toggleSupervisorTaskCheck));
router.post('/supervisor-board/reset', requireAuth, asyncHandler(taskBoardController.resetSupervisorBoard));
router.get('/trainer-board', requireAuth, asyncHandler(taskBoardController.getTrainerBoard));
router.post(
  '/trainer-board/trainees/:traineeUserId/tasks/:taskId/completion',
  requireAuth,
  asyncHandler(taskBoardController.toggleTrainerTraineeTaskCompletion)
);

module.exports = router;
