const dailyShiftReportService = require('../services/dailyShiftReportService');
const VALID_MEALS = new Set(['Breakfast', 'Lunch', 'Dinner']);

function assertValidMeal(meal) {
  if (typeof meal !== 'string' || !VALID_MEALS.has(meal)) {
    const error = new Error('InvalidMeal');
    throw error;
  }
}

function assertPayloadObject(payload) {
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) {
    const error = new Error('InvalidPayload');
    throw error;
  }
}

async function getCurrentLineReport(req, res, next) {
  try {
    if (req.query.meal != null) {
      assertValidMeal(req.query.meal);
    }

    const report = await dailyShiftReportService.getCurrentLineShiftReport({
      requesterUserId: Number(req.user.sub),
      requesterRole: req.user.role,
      meal: req.query.meal,
    });

    return res.json({ report });
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors can edit daily shift reports.' });
    }
    if (error.message === 'InvalidMeal') {
      return res.status(400).json({
        message: 'Invalid meal. Expected one of Breakfast, Lunch, Dinner.',
      });
    }
    return next(error);
  }
}

async function saveCurrentLineReportDraft(req, res, next) {
  try {
    assertValidMeal(req.body.meal);
    assertPayloadObject(req.body.payload);

    const report = await dailyShiftReportService.saveLineShiftReportDraft({
      requesterUserId: Number(req.user.sub),
      requesterRole: req.user.role,
      meal: req.body.meal,
      payload: req.body.payload,
    });

    return res.json(report);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors can edit daily shift reports.' });
    }
    if (error.message === 'InvalidMeal') {
      return res.status(400).json({
        message: 'Invalid meal. Expected one of Breakfast, Lunch, Dinner.',
      });
    }
    if (error.message === 'InvalidPayload') {
      return res.status(400).json({
        message: 'Invalid payload. Expected an object with report fields.',
      });
    }
    return next(error);
  }
}

async function submitCurrentLineReport(req, res, next) {
  try {
    assertValidMeal(req.body.meal);
    assertPayloadObject(req.body.payload);

    const report = await dailyShiftReportService.submitLineShiftReport({
      requesterUserId: Number(req.user.sub),
      requesterRole: req.user.role,
      meal: req.body.meal,
      payload: req.body.payload,
      appProfile: req.body.appProfile,
    });

    return res.json(report);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only supervisors can submit daily shift reports.' });
    }
    if (error.message === 'Incomplete') {
      return res.status(400).json({
        message: 'Daily shift report is incomplete.',
        missingFields: error.missingFields || [],
      });
    }
    if (error.message === 'InvalidMeal') {
      return res.status(400).json({
        message: 'Invalid meal. Expected one of Breakfast, Lunch, Dinner.',
      });
    }
    if (error.message === 'InvalidPayload') {
      return res.status(400).json({
        message: 'Invalid payload. Expected an object with report fields.',
      });
    }
    return next(error);
  }
}

async function listLineReports(req, res, next) {
  try {
    const reports = await dailyShiftReportService.listLineShiftReportsForLeadership({
      requesterRole: req.user.role,
    });

    return res.json(reports);
  } catch (error) {
    if (error.message === 'Unauthorized') {
      return res.status(403).json({ message: 'Only leadership can view daily shift reports.' });
    }
    return next(error);
  }
}

module.exports = {
  getCurrentLineReport,
  saveCurrentLineReportDraft,
  submitCurrentLineReport,
  listLineReports,
};
