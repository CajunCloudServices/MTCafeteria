const express = require('express');
const controller = require('../controllers/taskAdminController');
const { requireAuth } = require('../middleware/authMiddleware');
const { requireTaskEditorPassword } = require('../middleware/taskEditorAuth');

const router = express.Router();

// All task-admin routes require both a session (for audit context) and the
// dedicated task-editor password header. The password is a separate gate
// from the user role system so access can be granted to a specific operator
// without changing their role assignments. Middleware is scoped to the
// /task-admin path so it does not accidentally intercept unrelated routes
// (e.g. the global /api 404 handler).
router.use('/task-admin', requireAuth, requireTaskEditorPassword);

router.get('/task-admin/board', controller.getBoard);

router.post('/task-admin/jobs', controller.createJob);
router.patch('/task-admin/jobs/:jobId', controller.updateJob);
router.delete('/task-admin/jobs/:jobId', controller.deleteJob);

router.post('/task-admin/jobs/:jobId/tasks', controller.createTask);
router.patch('/task-admin/tasks/:taskId', controller.updateTask);
router.delete('/task-admin/tasks/:taskId', controller.deleteTask);

module.exports = router;
