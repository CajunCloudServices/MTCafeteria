# MTC Cafeteria Pilot

Pilot-only cafeteria operations app for Flutter web + Node/Express + PostgreSQL.

## What this repo is

This project is a shared operational app for MTC cafeteria workers and managers.
It is intentionally simple:

- no user login screen
- no employee account creation
- no profile system
- pilot-only launch path
- admin-only edits are gated inside the app by a password prompt

The app is focused on the pilot surfaces that workers actually use:

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
- `backend/sql/schema.sql` database schema
- `backend/sql/seed.sql` starter data
- `tools/` maintenance scripts and export helpers
- `artifacts/` OCR/transcription and audit outputs

## Content Sources

The app uses two kinds of content:

- bundled reference and training text in the Flutter app
- shared backend-backed overrides for admin edits

That means most of the text-heavy surfaces can be updated without rebuilding the entire app, while the 2-minute trainings remain static app content.

## Core API Areas

The backend serves these main domains:

- announcements and other shared content
- task board and supervisor board data
- training feeds for legacy compatibility

The pilot does not use a public login endpoint or user account flow.

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

There is no separate user login system for the pilot. The only interactive
gate is the in-app admin password prompt used for edit actions. On the backend
the same write routes are additionally role-gated (only callers in the
`Student Manager` role are allowed to mutate landing items). Network access to
the deployed API is restricted by the surrounding infrastructure (Coolify,
tunnel, firewall).

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

Default host ports in this repo’s current deploy setup:

- `WEB_HOST_PORT=3017`
- `API_HOST_PORT=4013`
- `DB_HOST_PORT=5436`

### Coolify deploy model

Coolify should build from committed files on `main`.
The deployed web image serves the tracked Flutter bundle in `public/flutter-web`.
That means Flutter source changes under `frontend_flutter/` are not deployable by themselves.
You must regenerate and commit `public/flutter-web` before pushing to `main`.

### Health checks

- web: `http://localhost:${WEB_HOST_PORT}/health`
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
- `POSTGRES_PASSWORD`
- `DATABASE_URL`

### Frontend deploy workflow

1. Make your Flutter changes under `frontend_flutter/`.

2. Rebuild and sync the tracked web bundle:

```bash
npm run flutter:web:sync
```

3. Commit both the source change and the regenerated bundle:

```bash
git add frontend_flutter public/flutter-web
git commit -m "Update Flutter frontend"
```

4. Push to `main`:

```bash
git push origin main
```

5. Coolify auto-deploys the updated tracked bundle from `main`.

The local `pre-push` hook blocks pushes that include `frontend_flutter/` changes without matching committed changes under `public/flutter-web/`.

### Backend or stack deploy checks

After Coolify deploys, verify health as needed:

```bash
npm run health:deploy
```

### Low-level bundle sync helper

If you already built Flutter web manually, you can still sync that output with:

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

The full daily shift report expects these fields on submit:

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

Pilot submissions (`appProfile: "pilot"`) only require a slimmed subset that
matches the cards actually shown in the pilot UI:

- `count`
- `deepClean`
- `entreeItemOutage`
- `productOutage`
- `productSurplus`
- `lockersChecked`
- `maintenanceConcerns`
- `generalComments`
- `summaries`

If incomplete, submit returns `400` with:

- `message: "Daily shift report is incomplete."`
- `missingFields: string[]`
