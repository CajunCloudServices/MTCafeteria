# Training Architecture

This repo currently contains two training-related systems. They serve different
purposes and should not be treated as interchangeable.

## Active Manual Training Viewer

This is the authoritative path for the detailed 2-minute training experience
that users open from the dashboard.

- Runtime content:
  `frontend_flutter/lib/pages/training/training_text_data.dart`
- Viewer UI:
  `frontend_flutter/lib/pages/training_detail_page.dart`
- Source-image/transcription workflow reference:
  `artifacts/mtcdocuments_vision_trainings_cleaned.json`
- Raw OCR reference:
  `artifacts/mtcdocuments_vision_output.json`

Notes:
- The app reads the Dart corpus directly at runtime.
- The OCR JSON files are workflow/reference artifacts, not runtime inputs.
- Manual transcription standards are documented in:
  `/Users/lajicpajam/Development/Apps/MTC Cafeteria/TRAININGS_TRANSCRIPTION_HANDOFF.md`

## Legacy API Training Feed

This is an older prototype path that remains in the codebase for compatibility
with older dashboard/panel flows.

- Frontend model:
  `frontend_flutter/lib/models/training.dart`
- Frontend state/API load:
  `frontend_flutter/lib/state/app_state/content.dart`
  `frontend_flutter/lib/services/api_client/api_client_content.dart`
- Backend route/controller/service:
  `backend/src/routes/trainingRoutes.js`
  `backend/src/controllers/trainingController.js`
  `backend/src/services/trainingService.js`

Notes:
- This feed returns simpler `title/content/assignedDate` records.
- It is not the source of truth for `TrainingDetailPage`.

## Maintenance Rules

- When updating actual 2-minute training content, update both:
  - `artifacts/mtcdocuments_vision_trainings_cleaned.json`
  - `frontend_flutter/lib/pages/training/training_text_data.dart`
- Use `tools/check_training_drift.py` to detect source-image mismatches between
  the cleaned JSON and the runtime Dart corpus.
- Avoid changing the legacy API feed unless you are intentionally working on
  the older prototype dashboard/panel path.
