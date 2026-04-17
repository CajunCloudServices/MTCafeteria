const express = require('express');
const trainingController = require('../controllers/trainingController');
const { requireAuth, requireRole } = require('../middleware/authMiddleware');
const { asyncHandler } = require('../middleware/asyncHandler');
const { TrainingRoles } = require('../config/roles');

const router = express.Router();

router.get('/trainings', requireAuth, requireRole(TrainingRoles), asyncHandler(trainingController.listTrainings));

module.exports = router;
