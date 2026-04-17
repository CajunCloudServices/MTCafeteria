const express = require('express');
const controller = require('../controllers/taskAdminController');
const { requireAuth } = require('../middleware/authMiddleware');
const { asyncHandler } = require('../middleware/asyncHandler');

const router = express.Router();

// Task-admin is now protected only by normal authenticated app access.
// The Student Manager Portal password is the UI gate; the backend only
// requires the logged-in session so the task editor does not prompt twice.
router.use('/task-admin', requireAuth);

router.get('/task-admin/board', asyncHandler(controller.getBoard));

router.post('/task-admin/jobs', asyncHandler(controller.createJob));
router.patch('/task-admin/jobs/:jobId', asyncHandler(controller.updateJob));
router.delete('/task-admin/jobs/:jobId', asyncHandler(controller.deleteJob));

router.post('/task-admin/jobs/:jobId/tasks', asyncHandler(controller.createTask));
router.patch('/task-admin/tasks/:taskId', asyncHandler(controller.updateTask));
router.delete('/task-admin/tasks/:taskId', asyncHandler(controller.deleteTask));

module.exports = router;
