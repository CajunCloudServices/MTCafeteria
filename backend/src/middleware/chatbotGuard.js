const env = require('../config/env');

const requestState = new Map();

function normalizeClientIp(req) {
  const forwardedFor = req.get('x-forwarded-for');
  if (typeof forwardedFor === 'string' && forwardedFor.trim()) {
    return forwardedFor.split(',')[0].trim();
  }
  return req.ip || req.socket?.remoteAddress || 'unknown';
}

function clientKey(req) {
  const userKey = req.user?.sub || req.user?.id || req.user?.email || 'anon';
  return `${userKey}:${normalizeClientIp(req)}`;
}

function getEntry(key, now = Date.now()) {
  const existing = requestState.get(key);
  if (!existing) {
    const created = {
      timestamps: [],
      active: 0,
      lastMessage: '',
      lastMessageAt: 0,
    };
    requestState.set(key, created);
    return created;
  }

  existing.timestamps = existing.timestamps.filter(
    (timestamp) => now - timestamp < env.chatbotRateLimitWindowMs
  );

  if (
    existing.timestamps.length === 0 &&
    existing.active === 0 &&
    now - existing.lastMessageAt >= env.chatbotDuplicateCooldownMs
  ) {
    requestState.delete(key);
    return getEntry(key, now);
  }

  return existing;
}

function releaseEntry(entry) {
  entry.active = Math.max(0, entry.active - 1);
}

function validateChatbotAccess(req, res, next) {
  if (!env.chatbotProxyEnabled) {
    res.status(503).json({ message: 'Chatbot is temporarily disabled.' });
    return;
  }

  const trimmedMessage = String(req.body?.message || '').trim();
  if (!trimmedMessage) {
    res.status(400).json({ message: 'Message is required.' });
    return;
  }
  if (trimmedMessage.length > env.chatbotMaxMessageChars) {
    res.status(400).json({
      message: `Message is too long. Maximum length is ${env.chatbotMaxMessageChars} characters.`,
    });
    return;
  }

  const trimmedSessionId = String(req.body?.sessionId || '').trim();
  if (trimmedSessionId.length > env.chatbotMaxSessionIdChars) {
    res.status(400).json({
      message: `Session id is too long. Maximum length is ${env.chatbotMaxSessionIdChars} characters.`,
    });
    return;
  }

  const key = clientKey(req);
  const now = Date.now();
  const entry = getEntry(key, now);

  if (entry.active >= env.chatbotMaxConcurrentRequests) {
    res.status(429).json({
      message: 'Chatbot is already handling a request for this session. Please wait a moment.',
    });
    return;
  }

  if (entry.timestamps.length >= env.chatbotRateLimitMaxRequests) {
    res.status(429).json({
      message: 'Chatbot rate limit reached. Please wait before sending another message.',
    });
    return;
  }

  if (
    entry.lastMessage === trimmedMessage &&
    now - entry.lastMessageAt < env.chatbotDuplicateCooldownMs
  ) {
    res.status(429).json({
      message: 'Duplicate chatbot message blocked. Please wait before retrying the same question.',
    });
    return;
  }

  entry.timestamps.push(now);
  entry.active += 1;
  entry.lastMessage = trimmedMessage;
  entry.lastMessageAt = now;

  let released = false;
  const release = () => {
    if (released) return;
    released = true;
    releaseEntry(entry);
  };

  res.on('finish', release);
  res.on('close', release);

  req.chatbotMessage = trimmedMessage;
  req.chatbotSessionId = trimmedSessionId;
  next();
}

module.exports = {
  validateChatbotAccess,
  _chatbotRequestState: requestState,
};
