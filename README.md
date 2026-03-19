# MTC Cafeteria Prototype (Flutter Web + PERN)

Lightweight prototype focused on organization and clarity for cafeteria workers.

## Stack
- Frontend: Flutter (web)
- Backend: Node.js + Express + PostgreSQL
- Auth: Basic email/password with JWT
- Data mode: Postgres-first (`USE_MOCK_DATA=false` in production)

## Project Structure
- `frontend_flutter/` Flutter web app (role-based dashboards + landing page)
- `backend/` Express API + PostgreSQL access layer
- `backend/sql/schema.sql` database schema
- `backend/sql/seed.sql` starter data

## Roles
- Employee
- Lead Trainer
- Supervisor
- Student Manager

## Training Sources
- Active detailed 2-minute training viewer: local manual corpus in `frontend_flutter/lib/pages/training/training_text_data.dart`
- OCR workflow artifacts: `artifacts/mtcdocuments_vision_output.json` and `artifacts/mtcdocuments_vision_trainings_cleaned.json`
- Legacy backend training feed: `GET /api/trainings` for older prototype dashboard/panel flows
- Architecture note: `TRAINING_ARCHITECTURE.md`

## Core API (Prototype)
- `POST /api/auth/login`
- `GET /api/content/landing-items`
- `POST /api/content/landing-items` (Student Manager, Supervisor)
- `PUT /api/content/landing-items/:id` (Student Manager, Supervisor)
- `DELETE /api/content/landing-items/:id` (Student Manager, Supervisor)
- `GET /api/trainings` (Lead Trainer, Supervisor, Student Manager)
- `GET /api/task-board`
- `POST /api/task-board/tasks/:taskId/completion`
- `GET /api/supervisor-board`
- `POST /api/supervisor-board/jobs/:jobId/check`
- `GET /api/supervisor-board/jobs/:jobId/tasks`
- `POST /api/supervisor-board/jobs/:jobId/tasks/:taskId/check`
- `POST /api/supervisor-board/reset`
- `GET /api/trainer-board`
- `POST /api/trainer-board/trainees/:traineeUserId/tasks/:taskId/completion`
- `GET /api/daily-shift-reports/current?meal=Breakfast|Lunch|Dinner`
- `PUT /api/daily-shift-reports/current`
- `POST /api/daily-shift-reports/current/submit`
- `GET /api/daily-shift-reports`

## Local Run
### 1) Backend
```bash
cd backend
cp .env.example .env
npm install
PORT=3201 npm run dev
```

Notes:
- In local development, you can use mock mode by setting `USE_MOCK_DATA=true` in `backend/.env`.
- For Postgres mode, set `USE_MOCK_DATA=false`, create DB, then run schema + seed SQL.

### 2) Flutter Web
```bash
cd frontend_flutter
flutter pub get
flutter run -d chrome
```

Runtime config (single source):
```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3201
```

Build profiles:
- `full` (default): all features
- `pilot`: tested/core features only (advanced modules hidden)

Pilot launch:
```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3201 \
  --dart-define=APP_PROFILE=pilot
```

Full launch:
```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3201 \
  --dart-define=APP_PROFILE=full
```

Optional feature overrides (for either profile):
```bash
--dart-define=FEATURE_MANAGER_PORTAL=on|off|auto
--dart-define=FEATURE_POINTS=on|off|auto
--dart-define=FEATURE_DAILY_SHIFT_REPORTS=on|off|auto
--dart-define=FEATURE_TRAININGS=on|off|auto
--dart-define=FEATURE_REFERENCES=on|off|auto
```

Development bypass (debug-only, visible DEV BYPASS badge):
```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=http://localhost:3201 \
  --dart-define=DEV_BYPASS_AUTH=true \
  --dart-define=APP_MODE=dev
```

## Test Accounts (Mock/Seed)
- `employee@mtc.local` / `password123`
- `trainer@mtc.local` / `password123`
- `supervisor@mtc.local` / `password123`
- `manager@mtc.local` / `password123`

## Scope Guardrails
- No audit logs
- Placeholder scheduling/job/task catalog content only

## TODO Hooks
- Add stronger validation and error-handling UX
- Expand shift/job/task authoring interfaces

## Production Deploy
This repo now matches the standard 3-service server pattern:
- `web`: Node static host for `public/flutter-web`, SPA fallback, and reverse proxy for `/api` and `/socket.io`
- `api`: Express backend on container port `4000`
- `postgres`: `postgres:15-alpine` with healthcheck

Flutter build artifacts are deployed into:
- `public/flutter-web`

### Default host ports
- `WEB_HOST_PORT=3017`
- `API_HOST_PORT=4013`
- `DB_HOST_PORT=5436`

Container ports stay fixed at:
- `web`: `3000`
- `api`: `4000`
- `postgres`: `5432`

### Health checks
- web: `http://localhost:${WEB_HOST_PORT}/health`
- api through web proxy: `http://localhost:${WEB_HOST_PORT}/api/health`
- api direct: `http://localhost:${API_HOST_PORT}/health`

### Preflight
Before first deploy, make sure the host ports are actually free:

```bash
ss -ltn | grep -E ':(3017|4013|5436)\b' || true
docker ps --format 'table {{.Names}}\t{{.Ports}}'
```

### First-time server setup
```bash
cd /home/lajicpajam/projects/websites/MTCafeteria
cp .env.example .env
chmod +x deploy_flutter_web.sh scripts/server_pull_and_deploy.sh scripts/server_redeploy_web.sh
```

Then set real values in `.env`:
- `APP_BASE_URL`
- `CORS_ORIGINS`
- `JWT_SECRET`
- `POSTGRES_PASSWORD`
- `DATABASE_URL`

### Deploy steps
1. Build Flutter web locally:

```bash
cd frontend_flutter
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=
```

2. Copy the Flutter build into the repo checkout on the server:

```bash
cd /home/lajicpajam/projects/websites/MTCafeteria
./deploy_flutter_web.sh /absolute/path/to/flutter/build/web
```

3. Pull latest code and rebuild the stack:

```bash
cd /home/lajicpajam/projects/websites/MTCafeteria
./scripts/server_pull_and_deploy.sh
```

4. Verify deploy health:

```bash
npm run health:deploy
```

### Web-only redeploy
If only the Flutter build changed and the backend did not:

```bash
cd /home/lajicpajam/projects/websites/MTCafeteria
./deploy_flutter_web.sh /absolute/path/to/flutter/build/web
./scripts/server_redeploy_web.sh
```

### Cloudflare Tunnel target
Point the tunnel for this app to:

```text
http://localhost:${WEB_HOST_PORT}
```

## Playwright Automation
Use a dedicated fixed-port profile so Playwright targets a stable URL.

1) Start backend on a fixed port (example: 3201)
```bash
cd backend
PORT=3201 npm run dev
```

2) Start Flutter test mode
```bash
cd frontend_flutter
flutter run -d chrome --web-port 51336 \
  --dart-define=API_BASE_URL=http://localhost:3201 \
  --dart-define=DEV_BYPASS_AUTH=true \
  --dart-define=APP_MODE=dev
```

## Canonical Local Launch Matrix
Backend:
```bash
cd backend
PORT=3201 npm run dev
```

Flutter web:
```bash
cd frontend_flutter
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3201
```

iOS simulator:
```bash
cd frontend_flutter
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:3201
```

## Daily Shift Report Payload (Line Supervisor)
Submit endpoint requires these keys to be non-empty:
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

3) Run automation scripts
```bash
npm run live:login:manager:html
npm run live:capture:dashboard
npm run live:screenshot -- http://localhost:51336
```

You can also pass action files directly:
```bash
node tools/live-site.js actions http://localhost:51336 @tools/live-actions/login-manager-html.json
```

## MobAI Audit Harness (Web-First)
Use MobAI to run repeatable UI audits with structured artifacts.

1) Ensure MobAI bridge is active on your simulator/device and app is open.

2) Initialize a timestamped audit run:
```bash
cd /Users/lajicpajam/projects/MTCafeteria
npm run mobai:audit:init
```

Desktop profile:
```bash
npm run mobai:audit:init:desktop
```

Artifacts are written to:
- `artifacts/mobai/<timestamp>/screenshots`
- `artifacts/mobai/<timestamp>/flow-notes.md`
- `artifacts/mobai/<timestamp>/issues.json`
- `artifacts/mobai/<timestamp>/before-after`

Path matrix and issue taxonomy are defined in:
- `tools/mobai/path-matrix.json`
- `tools/mobai/issues.schema.json`
