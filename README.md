# MTC Cafeteria

Cafeteria operations app for Flutter web + Node/Express + PostgreSQL.

## What this repo is

This project is a shared operational app for MTC cafeteria workers and managers.
It is intentionally simple:

- no user login screen
- no employee account creation
- no profile system
- admin-only edits are gated inside the app by a password prompt

The app is focused on the operational surfaces that workers actually use:

- Home / announcements
- Dashboard / shift workflows
- Guides / Find an Item / Dining Map / Recipes
- 2-minute Trainings
- admin editing for text-heavy content

## Stack

- Frontend: Flutter web
- Backend: Node.js + Express
- Database: PostgreSQL
- Admin model: in-app password gate for edit actions only

## Project Structure

- `frontend_flutter/` Flutter web app and all guide/training UI
- `backend/` Express API and PostgreSQL access layer
- `backend/sql/migrations/` versioned database schema migrations
- `backend/sql/seed.sql` starter data
- `tools/` maintenance scripts and export helpers
- `artifacts/` OCR/transcription and audit outputs

## Content Sources

The app uses two kinds of content:

- bundled reference and training text in the Flutter app
- shared backend-backed overrides for admin edits
- a remote MTC Dining chatbot reached through the local backend proxy

That means most of the text-heavy surfaces can be updated without rebuilding the entire app, while the 2-minute trainings remain static app content.

## Core API Areas

The backend serves these main domains:

- announcements and other shared content
- task board and supervisor board data
- training feeds for legacy compatibility
- chatbot proxy endpoints for the MTC Dining assistant

The app does not use a public login endpoint or user account flow.

## Local Development

### 1) Backend

```bash
cd backend
cp .env.example .env
npm install
PORT=3201 npm run dev
```

Notes:

- `USE_MOCK_DATA=true` gives you in-memory placeholder data for quick local testing.
- `USE_MOCK_DATA=false` uses PostgreSQL with the same API surface.
- For local browser testing, make sure `CORS_ORIGINS` includes the frontend origin.

### 2) Flutter Web

```bash
cd frontend_flutter
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3201
```

For a stable Playwright/browser automation session, use a fixed web port:

```bash
flutter run -d chrome --web-port 3006 --dart-define=API_BASE_URL=http://localhost:3201
```

## Admin Editing Model

Admin edits are intentionally simple and in-app:

- announcements can be added from the Home page
- guides and reference text can be edited from the dashboard editor
- inventory and task-note text can be edited through the shared content editor

There is no separate user login system. The only interactive gate is the
in-app admin password prompt used for edit actions. On the backend the same
write routes are additionally role-gated (only callers in the
`Student Manager` role are allowed to mutate landing items). Network access to
the deployed API should be restricted by the surrounding infrastructure and not
by public exposure of the API container itself.

## Scope Guardrails

- no user account management
- no login page
- no profile page
- no plugin system
- no arbitrary file upload flow
- no script execution features
- no background agents inside the app

## Production Deploy

The deployment model is a small 3-service stack:

- `web`: static Flutter web host and reverse proxy
- `api`: Express backend
- `postgres`: PostgreSQL database

Container ports stay fixed at:

- `web`: `3000`
- `api`: `4000`
- `postgres`: `5432`

Default host ports in this repo's current deploy setup:

- `WEB_HOST_PORT=3017`
- `API_HOST_PORT=4013`
- `DB_HOST_PORT=5436`

By default, only `web` is intended for public exposure.
`api` and `postgres` stay bound to localhost on the host machine unless you
change the compose file deliberately.

### Repo-owned deploy model

Deploys are defined in-repo now:

- CI validates backend tests, web host tests, Flutter analyze/test, and Docker image builds.
- The `web` Docker image **compiles Flutter web inside the build** (`web/Dockerfile`), copies the output to `public/flutter-web` in the image, then runs the Node host. You do **not** need to commit changes under `public/flutter-web` for Docker-based deploys to pick up Dart edits.
- The deploy workflow runs `scripts/deploy_production.sh`, which rebuilds containers and runs post-deploy health checks.

For **local** runs of the Node server against static files without rebuilding the image, use `npm run flutter:web:sync` so `public/flutter-web` exists on disk. Do not hand-edit generated files there.

### Health checks

- web liveness: `http://localhost:${WEB_HOST_PORT}/health`
- web readiness: `http://localhost:${WEB_HOST_PORT}/readyz`
- api through web proxy: `http://localhost:${WEB_HOST_PORT}/api/health`
- api direct: `http://localhost:${API_HOST_PORT}/health`

### First-time setup

```bash
cd /path/to/MTCafeteria
cp .env.example .env
npm install
npm run git-hooks:setup
```

Set the real values in `.env`:

- `APP_BASE_URL`
- `CORS_ORIGINS`
- `JWT_SECRET`
- `POSTGRES_PASSWORD`
- `DATABASE_URL`
- `TASK_EDITOR_PASSWORD`
- `CHATBOT_UPSTREAM_URL`
- `CHATBOT_API_TOKEN`

Database schema changes now flow through `backend/sql/migrations/`.
The backend container runs `npm run migrate` before startup, and local reseeding
still uses `npm --prefix backend run reseed` for explicit dev/bootstrap data.

### Frontend deploy workflow

1. Make your Flutter changes under `frontend_flutter/`.

2. Validate locally as needed:

```bash
cd frontend_flutter
flutter analyze
flutter test
```

3. Push your source changes:

```bash
git add frontend_flutter
git commit -m "Update Flutter frontend"
git push origin your-branch
```

4. CI rebuilds the production bundle from source and validates the Docker/web artifact.

5. When changes land on `main`, the deploy workflow rebuilds the bundle again on the production runner before bringing the stack up.

### Backend or stack deploy checks

After deploy completes, verify health as needed:

```bash
npm run health:deploy
npm run chatbot:smoke
```

Detailed chatbot architecture, remote host wiring, and break/fix steps:

- `docs/chatbot-integration.md`
- `docs/verification-runbook.md`

## Verification Standard

Do not rely on a successful deploy alone as evidence that the app is healthy.
The minimum release standard for this repo is:

- `npm --prefix backend test`
- `npm --prefix web test`
- `flutter analyze`
- `flutter test`
- Flutter production bundle rebuild from source
- post-deploy health checks

The full pre-push, pre-deploy, and post-deploy checklist is documented in:

- `docs/verification-runbook.md`

### Low-level bundle sync helper

If you already built Flutter web manually and want to smoke the Docker/web host locally, you can still sync that output with:

```bash
./deploy_flutter_web.sh /absolute/path/to/frontend_flutter/build/web
```

### Cloudflare Tunnel target

Point the tunnel for this app at:

```text
http://localhost:${WEB_HOST_PORT}
```

## Playwright / Browser Automation

Use a fixed web port when you want a repeatable browser target.

Example:

```bash
cd backend
PORT=3201 npm run dev

cd frontend_flutter
flutter run -d chrome --web-port 3006 --dart-define=API_BASE_URL=http://localhost:3201
```

## Daily Shift Report Payload

The daily shift report expects these fields on submit:

- `count`
- `late`
- `sick`
- `noShows`
- `deepClean`
- `seniorCashier`
- `juniorCashier`
- `specialtyMealsAttendantAndPlateCount`
- `oneOnOne`
- `shiftShoutout`
- `entreeItemOutage`
- `productOutage`
- `productSurplus`
- `lockersChecked`
- `maintenanceConcerns`
- `generalComments`
- `trainings`
- `serviceMissionariesPresentForShift`
- `summaries`

If incomplete, submit returns `400` with:

- `message: "Daily shift report is incomplete."`
- `missingFields: string[]`
