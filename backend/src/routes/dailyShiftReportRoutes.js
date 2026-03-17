const express = require('express');
const { requireAuth } = require('../middleware/authMiddleware');
const dailyShiftReportController = require('../controllers/dailyShiftReportController');

const router = express.Router();

router.get('/daily-shift-reports/current', requireAuth, dailyShiftReportController.getCurrentLineReport);
router.put('/daily-shift-reports/current', requireAuth, dailyShiftReportController.saveCurrentLineReportDraft);
router.post('/daily-shift-reports/current/submit', requireAuth, dailyShiftReportController.submitCurrentLineReport);
router.get('/daily-shift-reports', requireAuth, dailyShiftReportController.listLineReports);

module.exports = router;
