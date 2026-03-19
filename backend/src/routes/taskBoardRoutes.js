const express = require('express');
const taskBoardController = require('../controllers/taskBoardController');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

router.get('/task-board', requireAuth, taskBoardController.getTaskBoard);
router.post('/task-board/tasks/:taskId/completion', requireAuth, taskBoardController.toggleTaskCompletion);
router.post('/task-board/reset-flow', requireAuth, taskBoardController.resetTaskFlow);

router.get('/supervisor-board', requireAuth, taskBoardController.getSupervisorBoard);
router.post('/supervisor-board/jobs/:jobId/check', requireAuth, taskBoardController.toggleSupervisorJobCheck);
router.get('/supervisor-board/jobs/:jobId/tasks', requireAuth, taskBoardController.getSupervisorJobTasks);
router.post('/supervisor-board/jobs/:jobId/tasks/:taskId/check', requireAuth, taskBoardController.toggleSupervisorTaskCheck);
router.post('/supervisor-board/reset', requireAuth, taskBoardController.resetSupervisorBoard);
router.get('/trainer-board', requireAuth, taskBoardController.getTrainerBoard);
router.post(
  '/trainer-board/trainees/:traineeUserId/tasks/:taskId/completion',
  requireAuth,
  taskBoardController.toggleTrainerTraineeTaskCompletion
);

module.exports = router;
