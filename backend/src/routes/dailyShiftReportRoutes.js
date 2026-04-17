const express = require('express');
const { requireAuth } = require('../middleware/authMiddleware');
const { asyncHandler } = require('../middleware/asyncHandler');
const dailyShiftReportController = require('../controllers/dailyShiftReportController');

const router = express.Router();

router.get('/daily-shift-reports/current', requireAuth, asyncHandler(dailyShiftReportController.getCurrentLineReport));
router.put('/daily-shift-reports/current', requireAuth, asyncHandler(dailyShiftReportController.saveCurrentLineReportDraft));
router.post('/daily-shift-reports/current/submit', requireAuth, asyncHandler(dailyShiftReportController.submitCurrentLineReport));
router.get('/daily-shift-reports', requireAuth, asyncHandler(dailyShiftReportController.listLineReports));

module.exports = router;
