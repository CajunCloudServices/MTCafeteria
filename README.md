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

## Docker Deploy (Fast by Default)
The frontend container now serves prebuilt `frontend_flutter/build/web` assets using nginx. This avoids pulling the huge Flutter image every deploy.

1) First-time setup:
```bash
cd /home/lajicpajam/projects/MTCafeteria
cp .env.example .env
# set a strong JWT secret before continuing
sed -i 's|^JWT_SECRET=.*|JWT_SECRET=<strong-random-secret>|' .env
chmod +x deploy_web_stack.sh
```

2) Build web assets locally once, then deploy:
```bash
cd /home/lajicpajam/projects/MTCafeteria/frontend_flutter
flutter pub get
flutter build web --release --dart-define=API_BASE_URL=

cd /home/lajicpajam/projects/MTCafeteria
./deploy_web_stack.sh
```

3) Update on new commits:
```bash
cd /home/lajicpajam/projects/MTCafeteria
git pull --ff-only origin main
./deploy_web_stack.sh
```

Useful deploy flags:
- `./deploy_web_stack.sh --no-build` restart without rebuilding images
- `./deploy_web_stack.sh --build-frontend` force local flutter web rebuild first

If Flutter is unavailable locally and web assets are missing, deploy falls back automatically to `frontend_flutter/Dockerfile.builder` (slower dockerized Flutter build).

Default exposed ports:
- Frontend: `8086`
- Backend API: `3201`

Point your DNS record to the server IP, then browse:
- `http://<your-domain>:8086`

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
