const express = require('express');
const asyncHandler = require('../middleware/asyncHandler');
const { requireAuth } = require('../middleware/authMiddleware');
const { validateChatbotAccess } = require('../middleware/chatbotGuard');
const chatbotService = require('../services/chatbotService');

const router = express.Router();

router.get(
  '/chatbot/health',
  asyncHandler(async (_req, res) => {
    const health = await chatbotService.checkChatbotHealth();
    res.status(health.ok ? 200 : health.configured ? 503 : 503).json(health);
  })
);

router.post(
  '/chatbot/chat',
  requireAuth,
  validateChatbotAccess,
  asyncHandler(async (req, res) => {
    const reply = await chatbotService.sendChatMessage({
      message: req.chatbotMessage,
      sessionId: req.chatbotSessionId,
    });
    res.status(200).json(reply);
  })
);

module.exports = router;
