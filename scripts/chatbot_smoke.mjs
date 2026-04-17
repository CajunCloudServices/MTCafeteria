#!/usr/bin/env node

const baseUrl = (process.env.BACKEND_URL || 'http://127.0.0.1:3201').replace(/\/+$/, '');
const prompt = process.env.CHATBOT_SMOKE_PROMPT || 'What are the setup tasks for beverages?';

async function fetchJson(url, options = {}) {
  const response = await fetch(url, options);
  const text = await response.text();
  let body = null;
  try {
    body = text ? JSON.parse(text) : null;
  } catch (_) {
    body = text;
  }
  return { response, body };
}

async function main() {
  console.log(`Checking chatbot health via ${baseUrl}/api/chatbot/health ...`);
  const health = await fetchJson(`${baseUrl}/api/chatbot/health`);
  console.log(JSON.stringify(health.body, null, 2));

  console.log(`\nSending smoke prompt: ${prompt}`);
  const chat = await fetchJson(`${baseUrl}/api/chatbot/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: prompt }),
  });
  console.log(JSON.stringify(chat.body, null, 2));

  if (!health.response.ok || !chat.response.ok) {
    process.exitCode = 1;
  }
}

main().catch((error) => {
  console.error(error.stack || error.message || String(error));
  process.exit(1);
});
