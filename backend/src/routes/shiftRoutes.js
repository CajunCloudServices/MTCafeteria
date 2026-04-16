const express = require('express');
const shiftController = require('../controllers/shiftController');
const { requireAuth } = require('../middleware/authMiddleware');

const router = express.Router();

// Admin-facing read endpoint. Returns shifts with their jobs and tasks
// grouped by phase (Setup / During Shift / Cleanup). The pilot Flutter
// client does not consume this today; it is kept to support future admin
// tooling and to make the shift/job/task seed schema inspectable.
router.get('/shifts', requireAuth, shiftController.listShifts);

module.exports = router;
