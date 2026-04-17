# Validation Log

## 2026-04-17 - Guardrails for Flutter web deploy artifact

Verified after adding cross-platform Flutter web sync tooling and stricter pre-push checks.

Commands run:

- `npm --prefix backend test` -> pass (27/27)
- `npm --prefix web test` -> pass (9/9)
- `cd frontend_flutter && flutter analyze` -> pass (no issues)
- `cd frontend_flutter && flutter test` -> pass (14/14)
- `npm run flutter:web:sync -- --release --pwa-strategy=none` -> pass (build + sync complete)

Notes:

- The Flutter command warns that `--pwa-strategy` is deprecated upstream; build still succeeds.
- Existing test log lines that print expected failure-path exceptions are from intentional negative-path tests and do not indicate suite failure.
