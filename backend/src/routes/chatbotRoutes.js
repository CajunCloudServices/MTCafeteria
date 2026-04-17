const express = require('express');
const asyncHandler = require('../middleware/asyncHandler');
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
  asyncHandler(async (req, res) => {
    const reply = await chatbotService.sendChatMessage({
      message: req.body?.message,
      sessionId: req.body?.sessionId,
    });
    res.status(200).json(reply);
  })
);

module.exports = router;
