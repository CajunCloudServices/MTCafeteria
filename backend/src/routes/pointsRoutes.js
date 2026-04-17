const express = require('express');
const { requireAuth } = require('../middleware/authMiddleware');
const { asyncHandler } = require('../middleware/asyncHandler');
const pointsController = require('../controllers/pointsController');

const router = express.Router();

router.get('/points/assignable-users', requireAuth, asyncHandler(pointsController.listAssignableUsers));
router.post('/points/assignments', requireAuth, asyncHandler(pointsController.createAssignment));
router.get('/points/assignments/inbox', requireAuth, asyncHandler(pointsController.listInbox));
router.get('/points/assignments/sent', requireAuth, asyncHandler(pointsController.listSent));
router.get('/points/assignments/approval-queue', requireAuth, asyncHandler(pointsController.listManagerApprovalQueue));
router.post('/points/assignments/:id/approve', requireAuth, asyncHandler(pointsController.approveAssignment));
router.post('/points/assignments/:id/accept', requireAuth, asyncHandler(pointsController.acceptAssignment));

module.exports = router;
