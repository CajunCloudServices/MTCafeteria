const express = require('express');
const controller = require('../controllers/taskAdminController');
const { requireAuth } = require('../middleware/authMiddleware');
const { requireTaskEditorPassword } = require('../middleware/taskEditorAuth');
const { asyncHandler } = require('../middleware/asyncHandler');

const router = express.Router();

// All task-admin routes require both a session (for audit context) and the
// dedicated task-editor password header. The password is a separate gate
// from the user role system so access can be granted to a specific operator
// without changing their role assignments. Middleware is scoped to the
// /task-admin path so it does not accidentally intercept unrelated routes
// (e.g. the global /api 404 handler).
router.use('/task-admin', requireAuth, requireTaskEditorPassword);

router.get('/task-admin/board', asyncHandler(controller.getBoard));

router.post('/task-admin/jobs', asyncHandler(controller.createJob));
router.patch('/task-admin/jobs/:jobId', asyncHandler(controller.updateJob));
router.delete('/task-admin/jobs/:jobId', asyncHandler(controller.deleteJob));

router.post('/task-admin/jobs/:jobId/tasks', asyncHandler(controller.createTask));
router.patch('/task-admin/tasks/:taskId', asyncHandler(controller.updateTask));
router.delete('/task-admin/tasks/:taskId', asyncHandler(controller.deleteTask));

module.exports = router;
