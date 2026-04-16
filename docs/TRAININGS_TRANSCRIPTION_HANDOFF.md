# 2-Minute Trainings Handoff (Manual-First, Zero-Summary Policy)

This is the authoritative handoff for training transcription work in this repo.

Purpose:
- Preserve exactly what the user wanted.
- Prevent future assistants from repeating failed approaches.
- Provide a strict operational process that is easy to follow.

---

## 1) Repo + Path Guardrails (Do This First)

Work only in the checked-out root of this repository. This project has had path
confusion before with similarly named folders on contributor machines, so
confirm you are in the correct working tree before making edits.

Before making edits, run:

```bash
pwd
git rev-parse --show-toplevel
```

The two values should match and point at the repository root (the directory
that contains `backend/`, `frontend_flutter/`, and this file). If they do not,
stop and `cd` to the correct path.

---

## 2) What the User Explicitly Required

The user’s requirements are strict:

1. **Manual cleanup** of training text.
2. Keep **all meaningful operational content**.
3. Remove only obvious OCR garbage/noise (random header artifacts, non-relevant fragments, obvious nonsense).
4. Improve readability with sections and bullets.
5. **Do not summarize away details**.
6. Keep app output faithful to OCR intent.
7. Prefer direct edits over building parser/automation complexity for this phase.

### Explicitly disallowed behaviors

- Auto-condensing procedures into short summaries.
- “Smart cleanup” that deletes actionable details.
- Heavy parser logic introduced without request.
- Leaving JSON and app text out of sync.

---

## 3) Files Involved (Source of Truth)

## 3.1 Raw OCR input

- `artifacts/mtcdocuments_vision_output.json`

Used as the reference for what text exists in each image.

## 3.2 Manual cleaned OCR output

- `artifacts/mtcdocuments_vision_trainings_cleaned.json`

This is the editable cleaned corpus.

## 3.3 App-rendered training definitions

- `frontend_flutter/lib/pages/training/training_text_data.dart`

This is what users actually see in-app.

## 3.4 Training UI + flow behavior

- `frontend_flutter/lib/pages/training_detail_page.dart`
- `frontend_flutter/lib/widgets/shift_selection_cards.dart`

---

## 4) Training UI/Flow That Was Implemented

## 4.1 Area selection before training view

When opening 2-minute trainings, user must select:
- `Line`
- `Dishroom`

The selector uses the same shared card component style as shift-area:
- `ShiftTrackSelectionCard` from `shift_selection_cards.dart`

## 4.2 Track-specific training lists

Defined in `training_text_data.dart`:

- `buildLineTrainings()`
  - Shared 1–12 + Line 13–24

- `buildDishroomTrainings()`
  - Shared 1–12 + Dishroom-specific (current mapped set)

## 4.3 Rotation behavior

In `training_detail_page.dart`:
- Line and Dishroom have independent rotation starts.
- Dishroom excludes Sundays from rotation.
- Sunday dishroom selection shows notice and next non-Sunday training.

## 4.4 Back behavior

Back from training view returns to area selection first.
No extra “Change area” button required.

## 4.5 Visual background match

Trainings page uses same gradient layer as dashboard shell:
- `#F9FCFF` -> `#E7EEF9`

---

## 5) Manual Transcription Process (Exact SOP)

Use this for every training file:

1. Locate OCR text in `mtcdocuments_vision_output.json` by image filename.
2. Read full OCR block; identify garbage vs meaningful instruction.
3. Rewrite manually into coherent sections:
   - Keep all meaningful procedures and thresholds.
   - Preserve warnings, “DO NOT”, timings, locations, policy specifics.
4. Remove only non-meaningful artifacts:
   - random partial banner text
   - irrelevant language fragments not part of training
   - obvious OCR junk characters/line breaks
5. Update both:
   - `artifacts/mtcdocuments_vision_trainings_cleaned.json`
   - `frontend_flutter/lib/pages/training/training_text_data.dart`
6. Validate and run:
   - format + analyze
   - full app restart (not just hot reload)

---

## 6) Manual Editing Standards (Do/Don’t)

## 6.1 Do

- Preserve “how to” detail.
- Keep category headings clear.
- Keep procedural bullets atomic (1 instruction per bullet when possible).
- Keep policy language intact when it appears official.
- Fix capitalization/spelling where obvious.

## 6.2 Don’t

- Don’t reduce content to only 2–3 bullets if OCR includes more.
- Don’t remove nuance like exceptions, escalation paths, timing cutoffs.
- Don’t inject made-up policies.
- Don’t silently drop difficult lines; mark as unclear if needed.

---

## 7) Quality Gates Before Marking a Training “Done”

A training is done only if all pass:

1. **Completeness check**:
   - Every meaningful OCR instruction appears in cleaned/app text.

2. **Noise check**:
   - No random French/header artifacts unless intentionally kept as relevant.

3. **Readability check**:
   - Logical sections, consistent bulleting, no broken mid-sentence lines.

4. **App parity check**:
   - What is in `training_text_data.dart` matches cleaned intent.

5. **Build check**:
   - `flutter analyze` clean for touched files.

---

## 8) Validation Commands

From the repository root:

```bash
# Confirm training case mappings in app source
rg -n "case '.*\\.JPG'" frontend_flutter/lib/pages/training/training_text_data.dart

# Format touched files
dart format \
  frontend_flutter/lib/pages/training/training_text_data.dart \
  frontend_flutter/lib/pages/training_detail_page.dart

# Analyze touched files
flutter analyze \
  frontend_flutter/lib/pages/training/training_text_data.dart \
  frontend_flutter/lib/pages/training_detail_page.dart
```

Optional spot-check of cleaned-vs-raw length ratio (heuristic only):

```bash
python3 - <<'PY'
import json
from pathlib import Path
ocr=json.loads(Path('artifacts/mtcdocuments_vision_output.json').read_text())
clean=json.loads(Path('artifacts/mtcdocuments_vision_trainings_cleaned.json').read_text())
ocr_map={Path(i['file']).name:' '.join(i.get('text','').split()) for i in ocr if i.get('file','').startswith('2MinuteTrainings/')}
clean_map={Path(i['file']).name:' '.join(i.get('text','').split()) for i in clean if i.get('file','').startswith('2MinuteTrainings/')}
rows=[]
for k in sorted(set(ocr_map)&set(clean_map)):
    o=ocr_map[k]
    c=clean_map[k]
    if not o:
        continue
    rows.append((len(c)/len(o), k))
for ratio, name in sorted(rows)[:15]:
    print(f"{name}: {ratio:.3f}")
PY
```

Note: low ratio can be valid if OCR had heavy junk, but it is a strong review signal.

---

## 9) Known Areas That Need Ongoing Manual Attention

These images historically had more OCR issues and deserve stricter review:
- `Shared5.JPG`
- `Shared10.JPG`
- `Shared11.JPG`
- `Line13.JPG`
- `Line17.JPG`
- `Line23.JPG`
- `Line24.JPG`

Do not assume these are final forever; verify against raw OCR and real image intent each pass.

---

## 10) Change Tracking Discipline

For each manual batch:

1. List exactly which JPGs were edited.
2. State whether changes were:
   - content restoration
   - readability cleanup
   - noise removal only
3. Confirm both files were updated (JSON + app source).
4. Confirm analyze passed.

Use this response template in future chats:

```text
Batch complete: SharedX, LineY, LineZ
- Restored missing procedural detail: Yes/No
- Removed OCR junk: Yes/No
- JSON updated: Yes
- training_text_data.dart updated: Yes
- flutter analyze: pass
```

---

## 11) “Why didn’t it change in app?” Troubleshooting

If user says they still see old content:

1. Confirm correct repo path.
2. Confirm edited `frontend_flutter/lib/pages/training/training_text_data.dart` in this repo.
3. Full stop and re-run app (not hot reload only).
4. Verify user is viewing the expected track and training index/date.
5. Verify no accidental edits in a duplicate clone.

---

## 12) Strict Instructions for Next Assistant

If user says “manual,” do manual.

Do not:
- add parser pipelines,
- auto-summarize content,
- aggressively condense instructions.

Do:
- preserve operational detail,
- clean presentation,
- sync JSON and app source,
- validate and report precisely.

Success criteria:
- User sees complete, useful training instructions,
- minimal OCR garbage,
- no missing critical steps,
- stable UI behavior (track select, back behavior, rotation).

---

## 13) Current State Snapshot (At Time of This Handoff)

- Manual training content is sourced in `training_text_data.dart`.
- Track selector is implemented and styled with shared shift selector component.
- Back from training view returns to area selection.
- Gradient background now matches dashboard shell styling.
- Dishroom Sunday rule exists in training rotation logic.

If future behavior drifts from this, audit `training_detail_page.dart` first.

