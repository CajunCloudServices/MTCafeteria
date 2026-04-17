# MTC Chatbot Integration

This document covers the MTC Dining chatbot wiring that connects the Flutter app to the remote MTC knowledge bot on `lucien`.

## Architecture

The integration has four layers:

1. `lucien`
   `moltbot-mtc-api.service` runs the actual MTC Dining chatbot API.
2. MTC backend
   `backend/src/routes/chatbotRoutes.js` proxies the chatbot through same-origin `/api/chatbot/*`.
3. Flutter API client
   `frontend_flutter/lib/services/api_client/api_client_chatbot.dart` calls the backend proxy.
4. Global widget
   `frontend_flutter/lib/widgets/global_chat_widget.dart` renders the floating assistant available across the authenticated app shell.

The Flutter app never talks to `lucien` directly.

## Remote Host

Discovered service on `lucien`:

- systemd unit: `moltbot-mtc-api.service`
- code path: `/home/moltbot_mtc/web-api/server.js`
- health endpoint: `GET /health`
- chat endpoint: `POST /chat`

Required request body:

```json
{
  "message": "What are the setup tasks for beverages?",
  "sessionId": "optional-session-id"
}
```

Success response:

```json
{
  "reply": "Assistant response text",
  "sessionId": "session-id"
}
```

## Remote Binding Change

The MTC bot originally listened on `127.0.0.1:18910`, which made it unreachable from this app backend over Tailscale.

It was corrected with a systemd drop-in on `lucien`:

Path:

```text
/etc/systemd/system/moltbot-mtc-api.service.d/override.conf
```

Contents:

```ini
[Service]
Environment=HOST=100.84.218.4
```

After changes:

```bash
systemctl daemon-reload
systemctl restart moltbot-mtc-api.service
systemctl status moltbot-mtc-api.service
```

## App Backend Configuration

Set these in the repo `.env` used by the backend/container:

```env
CHATBOT_UPSTREAM_URL=http://100.84.218.4:18910
CHATBOT_API_TOKEN=...
CHATBOT_TIMEOUT_MS=65000
CHATBOT_PROXY_ENABLED=true
CHATBOT_MAX_MESSAGE_CHARS=300
CHATBOT_MAX_SESSION_ID_CHARS=120
CHATBOT_RATE_LIMIT_WINDOW_MS=60000
CHATBOT_RATE_LIMIT_MAX_REQUESTS=6
CHATBOT_MAX_CONCURRENT_REQUESTS=1
CHATBOT_DUPLICATE_COOLDOWN_MS=15000
```

Relevant backend files:

- `backend/src/config/env.js`
- `backend/src/services/chatbotService.js`
- `backend/src/routes/chatbotRoutes.js`
- `backend/src/server.js`

Backend proxy endpoints:

- `GET /api/chatbot/health`
- `POST /api/chatbot/chat`

## Abuse Protections

The backend proxy now enforces low-cost guardrails before the request ever
reaches the remote bot:

- `POST /api/chatbot/chat` requires authenticated app traffic
- request message length is capped
- session id length is capped
- duplicate messages are blocked briefly
- burst traffic is rate-limited in-memory by authenticated user + client IP
- only a small number of in-flight chatbot requests are allowed per user/IP
- the proxy can be shut off immediately with `CHATBOT_PROXY_ENABLED=false`

These limits are intentionally conservative because this bot is budget-limited.
If you only have a small balance, keep the defaults small and lower them
further before expanding usage.

## Frontend Files

- `frontend_flutter/lib/models/chatbot.dart`
- `frontend_flutter/lib/services/api_client/api_client_chatbot.dart`
- `frontend_flutter/lib/widgets/global_chat_widget.dart`
- `frontend_flutter/lib/main.dart`

The chat launcher is global and remains available across authenticated screens.

## Local Verification

Backend tests:

```bash
npm --prefix backend test
```

Flutter tests:

```bash
cd frontend_flutter
flutter analyze
flutter test
```

Proxy smoke test against a running local backend:

```bash
npm run chatbot:smoke
```

Optional custom prompt:

```bash
CHATBOT_SMOKE_PROMPT="Where do I find vitamin water?" npm run chatbot:smoke
```

## Direct Remote Diagnostics

Health from this machine:

```bash
curl http://100.84.218.4:18910/health
```

Check service state on `lucien`:

```bash
ssh lucien "systemctl status moltbot-mtc-api.service --no-pager"
ssh lucien "systemctl show -p Environment moltbot-mtc-api.service"
```

Direct chat smoke on `lucien`:

```bash
ssh lucien 'TOKEN=$(cat /etc/moltbot/creds/mtc_chat_api_token); \
curl -X POST http://100.84.218.4:18910/chat \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Content-Type: application/json" \
  -d "{\"message\":\"What are the setup tasks for beverages?\",\"sessionId\":\"ops-smoke\"}"'
```

## When the UI shows `502` and HTML (`<!DOCTYPE html>`, Cloudflare `cf-` classes)

That response body is almost always an **HTML error page from a proxy or CDN**, not the Express JSON errors this app returns. Typical causes:

1. **The browser never reached your Node API** (Cloudflare ↔ origin connectivity, TLS mode, or origin down). Confirm other `/api/*` routes work from the same browser session.
2. **The `web` container cut off a long chat request** before the API finished. The web host sets a long proxy timeout for `/api` (see `API_PROXY_TIMEOUT_MS` in `web/server.js`); ensure production env matches.
3. **The API container cannot reach `CHATBOT_UPSTREAM_URL`** (Tailscale routing, firewall, or wrong URL/token). The backend would normally return JSON `{ "message": "Could not reach chatbot service: ..." }` — if you only ever see HTML, suspect (1) or (2) first.

The Flutter client uses a **longer HTTP timeout for chatbot calls** than other API methods so slow remote bot replies are not aborted at 15 seconds.

## Failure Checklist

If the widget opens but does not answer:

1. Check backend proxy health:

```bash
curl http://localhost:3201/api/chatbot/health
```

2. If proxy says `configured: false`, verify `.env` contains:
   `CHATBOT_UPSTREAM_URL`, `CHATBOT_API_TOKEN`

3. If proxy says unavailable, test `lucien` health directly:

```bash
curl http://100.84.218.4:18910/health
```

4. If `lucien` health fails, inspect the remote service:

```bash
ssh lucien "systemctl status moltbot-mtc-api.service --no-pager"
ssh lucien "journalctl -u moltbot-mtc-api.service -n 200 --no-pager"
```

5. If `lucien` health passes but backend chat fails, verify the API token configured for this app backend matches `/etc/moltbot/creds/mtc_chat_api_token` on `lucien`.

6. If backend proxy works but the widget fails, run:

```bash
cd frontend_flutter
flutter test
```

Focus on:

- `test/global_chat_widget_test.dart`
- `test/runtime_config_test.dart`

## Regression Coverage

Backend:

- `backend/test/server.test.js`
  verifies disabled-chatbot handling, auth enforcement, rate limits,
  duplicate blocking, concurrency limits, and proxy forwarding behavior

Frontend:

- `frontend_flutter/test/global_chat_widget_test.dart`
  verifies widget open/send flow
- `frontend_flutter/test/runtime_config_test.dart`
  verifies chatbot feature flag wiring

## Notes

- The backend proxy intentionally keeps the chatbot token out of the Flutter client.
- The Flutter widget should be treated as a convenience surface, not the source of truth for diagnostics. Use `/api/chatbot/*` and `lucien` service checks first when debugging.
