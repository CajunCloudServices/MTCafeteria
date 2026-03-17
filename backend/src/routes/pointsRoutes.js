const express = require('express');
const { requireAuth } = require('../middleware/authMiddleware');
const pointsController = require('../controllers/pointsController');

const router = express.Router();

router.get('/points/assignable-users', requireAuth, pointsController.listAssignableUsers);
router.post('/points/assignments', requireAuth, pointsController.createAssignment);
router.get('/points/assignments/inbox', requireAuth, pointsController.listInbox);
router.get('/points/assignments/sent', requireAuth, pointsController.listSent);
router.get('/points/assignments/approval-queue', requireAuth, pointsController.listManagerApprovalQueue);
router.post('/points/assignments/:id/approve', requireAuth, pointsController.approveAssignment);
router.post('/points/assignments/:id/accept', requireAuth, pointsController.acceptAssignment);

module.exports = router;
