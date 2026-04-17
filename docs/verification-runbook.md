# Verification Runbook

This document is the operational checklist for validating MTCafeteria before
merge, before deploy, and after deploy. It exists to catch the specific
regressions that have already occurred in this repo:

- dashboard manager controls disappearing unexpectedly
- task editor opening without the required auth headers
- generated Flutter web assets drifting from source changes
- chatbot launcher rendering correctly while the backend proxy is broken
- production deploys completing while critical routes are still unhealthy

Use this file as the source of truth for release verification.

## Critical User Flows

The following flows are release-blocking:

1. Dashboard hub renders `Student Manager Portal` under `2-minute Trainings`.
2. Entering the student manager password unlocks the portal for the current
   session.
3. `Edit Announcements`, `Assign Points`, `Daily Shift Reports`, and
   `Edit Jobs & Tasks` are reachable from the portal.
4. `Edit Jobs & Tasks` loads the board successfully from `/api/task-admin/board`
   without a second unlock prompt after the portal has already been unlocked.
5. Employee task checklist checkboxes update immediately, persist after the API
   call succeeds, and roll back on failure.
6. Global chatbot launcher is visible on authenticated screens, opens, reports
   health correctly, and can send a chat request through the backend proxy.
7. `web`, `api`, and database readiness checks pass after deploy.
8. Chatbot abuse limits still hold:
   unauthenticated chat is rejected, burst traffic is limited, and duplicate
   requests are blocked.

If any of these fail, treat the release as incomplete.

## Automated Test Inventory

### Backend

Run:

```bash
npm --prefix backend test
```

Coverage currently includes:

- strict auth and role checks on protected routes
- task-admin dual-factor requirement:
  JWT auth + `X-Task-Editor-Password`
- employee task completion persistence
- async error normalization into structured `500` responses
- readiness behavior when Postgres is unavailable
- chatbot proxy disabled mode and forwarding mode
- chatbot auth requirement, message-size validation, duplicate blocking,
  burst limiting, and concurrency limiting

Primary file:

- `backend/test/server.test.js`

Supporting files:

- `backend/test/authMiddleware.test.js`
- `backend/test/env.test.js`

### Flutter frontend

Run:

```bash
cd frontend_flutter
flutter analyze
flutter test
```

Coverage currently includes:

- dashboard hub shows `Student Manager Portal` in the correct location
- employee checklist optimistic updates and rollback behavior
- runtime config feature resolution
- global chatbot launcher open/send behavior
- task editor initial load sends both required auth headers:
  `Authorization: Bearer ...` and `X-Task-Editor-Password`
- task editor auth failures render a visible error state instead of a silent
  blank page

Primary files:

- `frontend_flutter/test/dashboard_hub_card_test.dart`
- `frontend_flutter/test/widget_test.dart`
- `frontend_flutter/test/global_chat_widget_test.dart`
- `frontend_flutter/test/runtime_config_test.dart`
- `frontend_flutter/test/task_editor_page_test.dart`

### Web host

Run:

```bash
npm --prefix web test
```

Coverage currently includes:

- `/health`
- `/readyz`
- `/api/health` proxying
- static cache headers
- SPA fallback behavior
- missing-bundle failure behavior

Primary file:

- `web/test/server.test.js`

## Required Local Validation Before Push

Run this minimum set before pushing UI, auth, or deploy changes:

```bash
npm --prefix backend test
npm --prefix web test
cd frontend_flutter
flutter analyze
flutter test
cd ..
bash ./scripts/build_and_sync_flutter_web.sh --release --pwa-strategy=none
docker compose build web api
```

If the change touches deploy/runtime behavior, also run:

```bash
ENV_FILE=.env.ci node ./scripts/post_deploy_healthcheck.mjs
```

Or bring the stack up with CI-like env and smoke it end-to-end:

```bash
docker compose --env-file .env.ci up -d --build --remove-orphans
ENV_FILE=.env.ci node ./scripts/post_deploy_healthcheck.mjs
docker compose --env-file .env.ci down -v
```

## Release Checklist

Before merging or deploying:

1. Confirm automated checks passed:
   `backend`, `web`, `flutter analyze`, `flutter test`, Flutter web build.
2. Confirm the generated web bundle was rebuilt from source:
   `bash ./scripts/build_and_sync_flutter_web.sh --release --pwa-strategy=none`
3. Confirm any task editor changes were validated against both required headers.
4. Confirm chatbot changes were validated through `/api/chatbot/health` and
   `/api/chatbot/chat`, not just the widget shell.
5. Confirm deploy workflow and local scripts still point at the same health
   contract: `/health`, `/readyz`, and `/api/health`.

## Post-Deploy Verification

### Health

Run:

```bash
npm run health:deploy
```

This validates:

- web liveness
- web readiness
- API health through the web proxy
- direct API health when `API_HOST_PORT` is set

### Chatbot

Run:

```bash
npm run chatbot:smoke
```

If that fails, use the deeper diagnostics in `./chatbot-integration.md`.

### Manual browser spot-check

Use one real authenticated browser session and verify:

1. Dashboard shows `Student Manager Portal`.
2. Opening the portal asks for the student manager password once.
3. `Edit Jobs & Tasks` opens the board and does not show
   `Authentication required.`
4. Chat launcher appears as a bot icon, not a text button.
5. Chatbot can answer a simple operational question.

## Break/Fix Guidance

### Portal button missing

Check:

- `frontend_flutter/lib/widgets/dashboard_hub_card.dart`
- `frontend_flutter/lib/app/main_shell.dart`
- generated `public/flutter-web/main.dart.js`

Then run:

```bash
cd frontend_flutter
flutter test test/dashboard_hub_card_test.dart
```

### Task editor opens but shows `Authentication required.`

This usually means the page is missing the session JWT, the task editor
password header, or both.

Check:

- `frontend_flutter/lib/main.dart`
- `frontend_flutter/lib/pages/task_editor_page.dart`
- `frontend_flutter/lib/services/api_client/api_client_task_admin.dart`
- `backend/src/routes/taskAdminRoutes.js`

Then run:

```bash
cd frontend_flutter
flutter test test/task_editor_page_test.dart
```

And confirm backend expectations:

```bash
npm --prefix backend test
```

### Chat widget opens but cannot answer

Check:

- `/api/chatbot/health`
- `/api/chatbot/chat`
- `docs/chatbot-integration.md`

Then run:

```bash
cd frontend_flutter
flutter test test/global_chat_widget_test.dart
cd ..
npm --prefix backend test
npm run chatbot:smoke
```

If you suspect spend leakage or abuse, temporarily disable the proxy at the
backend edge:

```bash
CHATBOT_PROXY_ENABLED=false
```

Then redeploy and verify `/api/chatbot/health` reports `disabled`.

### Source looks correct but production looks stale

Assume generated assets are stale until proven otherwise.

Rebuild and sync:

```bash
bash ./scripts/build_and_sync_flutter_web.sh --release --pwa-strategy=none
```

Then validate the served `main.dart.js` contains the expected strings or
behavior before declaring the deploy complete.
