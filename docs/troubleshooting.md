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

This repo deploys the **built Flutter web artifact** from `public/flutter-web`, not raw Dart source.

A source-only fix in `frontend_flutter/lib/...` does **not** reach production until the Flutter web bundle is rebuilt and synced into `public/flutter-web`.

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

Check `https://mtcdining.cajuncloudservices.com/main.dart.js` for expected updated strings/markers from the fix.

If markers are missing, production is serving an older bundle.

### C) Confirm runtime containers are on expected image tag

On `arceneaux` -> container `105`, verify current app containers and image tags for `web` and `api`.

If tags do not match intended commit, recreate/redeploy services.

## Recovery Procedure

If a fix is already in source but not effective live, do all steps below:

1. Ensure fix is committed and pushed to `main`.
2. Build + sync Flutter web artifact:
   - `npm run flutter:web:sync -- --release --pwa-strategy=none`
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
2. Verify Flutter bundle rebuilt and synced.
   - pre-push now blocks frontend-only pushes without `public/flutter-web` updates.
3. Verify live container image tags correspond to fix commit.
4. Verify API endpoints with auth token.
5. Verify UI flow manually in browser after hard refresh.

Use `docs/verification-runbook.md` alongside this file for full pre-deploy and post-deploy checks.
