const express = require('express');
const contentController = require('../controllers/contentController');
const { attachUserIfPresent, requireAuth, requireRole } = require('../middleware/authMiddleware');
const { asyncHandler } = require('../middleware/asyncHandler');
const { AdminLandingRoles } = require('../config/roles');

const router = express.Router();

router.get('/landing-items', attachUserIfPresent, asyncHandler(contentController.listLandingItems));
router.post('/landing-items', requireAuth, requireRole(AdminLandingRoles), asyncHandler(contentController.createLandingItem));
router.put('/landing-items/:id', requireAuth, requireRole(AdminLandingRoles), asyncHandler(contentController.updateLandingItem));
router.delete('/landing-items/:id', requireAuth, requireRole(AdminLandingRoles), asyncHandler(contentController.deleteLandingItem));

module.exports = router;
