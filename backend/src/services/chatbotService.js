const env = require('../config/env');

class ChatbotProxyError extends Error {
  constructor(message, { statusCode = 502, expose = true } = {}) {
    super(message);
    this.name = 'ChatbotProxyError';
    this.statusCode = statusCode;
    this.expose = expose;
  }
}

function isChatbotConfigured() {
  return env.chatbotProxyEnabled && Boolean(env.chatbotUpstreamUrl);
}

function joinUrl(baseUrl, routePath) {
  return `${String(baseUrl).replace(/\/+$/, '')}${routePath}`;
}

async function parseJsonSafe(response) {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch (_) {
    return { message: text };
  }
}

function buildHeaders(json = false) {
  const headers = {};
  if (json) {
    headers['Content-Type'] = 'application/json';
  }
  if (env.chatbotApiToken) {
    headers.Authorization = `Bearer ${env.chatbotApiToken}`;
  }
  return headers;
}

async function fetchUpstream(routePath, options = {}, fetchImpl = fetch) {
  if (!isChatbotConfigured()) {
    throw new ChatbotProxyError('Chatbot service is not configured.', {
      statusCode: 503,
    });
  }

  try {
    return await fetchImpl(joinUrl(env.chatbotUpstreamUrl, routePath), {
      ...options,
      signal: AbortSignal.timeout(env.chatbotTimeoutMs),
    });
  } catch (error) {
    throw new ChatbotProxyError(
      `Could not reach chatbot service: ${error.message || String(error)}.`,
      { statusCode: 502 }
    );
  }
}

async function checkChatbotHealth(fetchImpl = fetch) {
  try {
    if (!env.chatbotProxyEnabled) {
      return {
        ok: false,
        configured: false,
        status: 'disabled',
        message: 'Chatbot is temporarily disabled.',
      };
    }

    const response = await fetchUpstream(
      '/health',
      {
        method: 'GET',
        headers: buildHeaders(),
      },
      fetchImpl
    );
    const payload = await parseJsonSafe(response);
    if (!response.ok) {
      return {
        ok: false,
        configured: true,
        status: 'unavailable',
        upstreamStatus: response.status,
        message: payload?.message || payload?.error || 'Chatbot health check failed.',
      };
    }

    return {
      ok: true,
      configured: true,
      status: 'ok',
      upstreamStatus: response.status,
      payload: payload || { ok: true },
    };
  } catch (error) {
    if (error instanceof ChatbotProxyError && error.statusCode === 503) {
      return {
        ok: false,
        configured: false,
        status: 'disabled',
        message: error.message,
      };
    }

    return {
      ok: false,
      configured: true,
      status: 'unavailable',
      message: error.message || 'Chatbot health check failed.',
    };
  }
}

async function sendChatMessage({ message, sessionId }, fetchImpl = fetch) {
  const trimmedMessage = String(message || '').trim();
  if (!trimmedMessage) {
    throw new ChatbotProxyError('Message is required.', { statusCode: 400 });
  }
  if (trimmedMessage.length > env.chatbotMaxMessageChars) {
    throw new ChatbotProxyError(
      `Message is too long. Maximum length is ${env.chatbotMaxMessageChars} characters.`,
      { statusCode: 400 }
    );
  }

  const trimmedSessionId = String(sessionId || '').trim();
  if (trimmedSessionId.length > env.chatbotMaxSessionIdChars) {
    throw new ChatbotProxyError(
      `Session id is too long. Maximum length is ${env.chatbotMaxSessionIdChars} characters.`,
      { statusCode: 400 }
    );
  }

  const response = await fetchUpstream(
    '/chat',
    {
      method: 'POST',
      headers: buildHeaders(true),
      body: JSON.stringify({
        message: trimmedMessage,
        ...(trimmedSessionId ? { sessionId: trimmedSessionId } : {}),
      }),
    },
    fetchImpl
  );

  const payload = await parseJsonSafe(response);
  if (!response.ok) {
    const messageText =
      payload?.message || payload?.error || 'Chatbot request failed.';
    throw new ChatbotProxyError(messageText, {
      statusCode:
        response.status === 400 ||
        response.status === 429 ||
        response.status === 504
          ? response.status
          : 502,
    });
  }

  const reply = String(payload?.reply || '').trim();
  if (!reply) {
    throw new ChatbotProxyError('Chatbot reply was empty.', { statusCode: 502 });
  }

  return {
    reply,
    sessionId: String(payload?.sessionId || trimmedSessionId || '').trim(),
  };
}

module.exports = {
  ChatbotProxyError,
  checkChatbotHealth,
  isChatbotConfigured,
  sendChatMessage,
};
