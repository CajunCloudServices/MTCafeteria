# Troubleshooting Guide

This document captures common production breakages seen in the MTC Cafeteria app and the fastest way to diagnose and fix them.

## Symptoms We Saw

- Supervisor/Trainer/Employee workflows stuck on:
  - `Loading task board...`
  - `Loading trainer board...`
  - `Loading supervisor board...`
- Student Manager Portal buttons appear but actions do not proceed.
- Daily Shift Reports appear empty or never load in portal view.
- Fixes are merged/pushed but live site behavior does not change.

## Root Causes

### 1) Role-switch board load gap

When users select a line role after track selection, the app must immediately fetch that role's board:

- Employee -> task board
- Lead Trainer -> trainer board
- Supervisor -> supervisor board

If this fetch is not triggered after role confirmation, the UI can remain in a loading state.

### 2) Bootstrap/session hydration fragility

Manager mode/session changes can succeed for auth but still fail overall if a downstream refresh call throws. If errors are not handled as best-effort, UI state can look "unlocked" while dependent data never appears.

### 3) Deployment artifact mismatch

The public host currently consumes the prebuilt Flutter bundle under `public/flutter-web`. If production still serves an old UI, the usual causes are:

- `frontend_flutter/` changed but `public/flutter-web` was never refreshed
- the host rebuilt from repo source but used the stale committed bundle
- the running container is still an older image built before the refreshed bundle landed

If you run the Node web server **without** Docker, it reads `public/flutter-web` from disk; you still must run `npm run flutter:web:sync` after Dart changes.

## Quick Diagnostic Checklist

Run these checks in order.

### A) Confirm live API is healthy and role endpoints respond

1. Login as supervisor or manager via `/api/auth/login`.
2. Verify these endpoints with `Authorization: Bearer <token>`:
   - `/api/task-board`
   - `/api/trainer-board`
   - `/api/supervisor-board`
   - `/api/daily-shift-reports`
3. If API calls return 200 and payloads but UI still spins, suspect frontend bundle/client-state issue.

### B) Confirm live bundle actually contains latest changes

Check `https://mtcdining.cajuncloudservices.com/main.dart.js` for expected updated strings, hashes, or other markers from the fix.

If the expected markers are missing, production is serving an older bundle.

### C) Confirm runtime containers are on expected image tag

On `arceneaux` -> container `105`, verify current app containers and image tags for `web` and `api`.

If tags do not match intended commit, recreate/redeploy services.

## Recovery Procedure

If a fix is already in source but not effective live, do all steps below:

1. Ensure fix is committed and pushed to `main`.
2. Run `npm run flutter:web:sync -- --release --pwa-strategy=none`.
3. Commit/push the refreshed `public/flutter-web` bundle if the host rebuilds directly from repo source (current Coolify-style path).
4. Sync updated repo content to live app directory in Coolify app source.
5. Rebuild/recreate live `web` and `api` services.
6. Re-check:
   - public bundle content (`main.dart.js`)
   - API role endpoints
   - UI flow behavior in browser

## UI Hardening Expectations

Workflow sections should never dead-end silently:

- If board is null, show loading plus a visible `Retry` action.
- Entering a role should proactively refresh that role's board.
- Session elevation should be resilient to non-critical refresh failures.

## Prevent Recurrence

Before declaring a production fix complete:

1. Verify source fix is committed.
2. Verify `public/flutter-web` was refreshed from current Flutter source.
3. Verify the deployed `web` image was rebuilt from that refreshed bundle.
4. Verify live container image tags correspond to fix commit.
5. Verify API endpoints with auth token.
6. Verify UI flow manually in browser after hard refresh.

Use `docs/verification-runbook.md` alongside this file for full pre-deploy and post-deploy checks.
