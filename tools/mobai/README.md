# MobAI Audit Toolkit

Web-first audit helpers for the MTC Dining app.

## Files
- `path-matrix.json`: required path coverage IDs.
- `issues.schema.json`: issue taxonomy schema.
- `issues.template.json`: starter issue list.
- `flow-notes.template.md`: run-note template.
- `scenarios/*.json`: reusable scenario definitions.

## Quick Start
1. Ensure MobAI bridge is active on your device/simulator.
2. Ensure app is running and reachable.
3. Run:

```bash
npm run mobai:audit:init
```

This creates:
- `artifacts/mobai/<timestamp>/screenshots`
- `artifacts/mobai/<timestamp>/flow-notes.md`
- `artifacts/mobai/<timestamp>/issues.json`
- `artifacts/mobai/<timestamp>/before-after`

## Notes
- If `web/navigate` is unavailable, open the app manually in simulator first.
- Use path IDs in `path-matrix.json` when recording issues.
