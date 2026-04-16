# MTCafeteria Documentation

This folder contains supporting architecture, operations, and handoff notes
that do not belong in the top-level `README.md`. The top-level `README.md`
remains the source of truth for getting the stack running; everything in here
is reference material for deeper work.

## Contents

- `TRAINING_ARCHITECTURE.md` — high-level map of the two training systems
  (active manual viewer vs. legacy API feed) and how they relate.
- `TRAININGS_TRANSCRIPTION_HANDOFF.md` — strict manual-first SOP for editing
  2-minute training content so it stays faithful to the source images.
- `implementation-guide.md` — end-to-end implementation guide for the pilot
  build (architecture, deploy, seed data, smoke checks).
- `kubernetes-architecture.md` — reference architecture for a future
  Kubernetes deployment. Not used by the current Docker Compose / Coolify
  setup.
- `PILOT_FEATURE_PRIORITIZATION.md` — prioritization write-up that backs the
  `PILOT_FEATURE_PRIORITIZATION.csv` and `PILOT_FEATURE_RANKING.csv` sheets
  at the repo root.

## Conventions

- Keep these docs self-contained and link with relative paths (e.g.
  `./TRAINING_ARCHITECTURE.md`) so they work both on disk and when viewed on
  GitHub.
- Do not put code/config that the app actually reads at runtime in here;
  runtime assets live under `backend/`, `frontend_flutter/assets/`, and
  `artifacts/`.
