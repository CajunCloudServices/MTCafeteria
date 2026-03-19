#!/usr/bin/env python3
"""Export clean 2-minute trainings from training_text_data.dart."""

from __future__ import annotations

import json
import re
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path("/Users/lajicpajam/Development/active/Apps/MTCafeteria")
DART_FILE = ROOT / "frontend_flutter/lib/pages/training/training_text_data.dart"
OUT_JSON = ROOT / "artifacts/2minute_trainings_clean.json"


def _extract_block(text: str, fn_name: str) -> str:
    marker = f"List<TrainingTextContent> {fn_name}() => <TrainingTextContent>["
    start = text.find(marker)
    if start < 0:
        raise ValueError(f"Could not find block for {fn_name}")
    block_start = text.find("[", start)
    block_end = text.find("];", block_start)
    if block_start < 0 or block_end < 0:
        raise ValueError(f"Malformed block for {fn_name}")
    return text[block_start + 1 : block_end]


def _extract_entries(block: str) -> list[dict]:
    pattern = re.compile(
        r"parseTrainingText\(\s*title:\s*'([^']+)'\s*,\s*sourceImage:\s*'([^']+)'\s*,\s*raw:\s*r'''(.*?)'''\s*\),",
        flags=re.S,
    )
    entries = []
    for m in pattern.finditer(block):
        title = m.group(1).strip()
        source_image = m.group(2).strip()
        raw = m.group(3).replace("\r", "\n").strip()
        lines = [ln.strip() for ln in raw.split("\n") if ln.strip()]
        objective = next(
            (
                ln.split(":", 1)[1].strip()
                for ln in lines
                if ln.lower().startswith("objective:")
            ),
            "Review this training with your team.",
        )
        entries.append(
            {
                "title": title,
                "source_image": source_image,
                "objective": objective,
                "text": raw,
                "lines": lines,
            }
        )
    return entries


def main() -> None:
    text = DART_FILE.read_text(encoding="utf-8")
    shared = _extract_entries(_extract_block(text, "_sharedTrainings"))
    line = _extract_entries(_extract_block(text, "buildLineTrainings"))
    dishroom = _extract_entries(_extract_block(text, "buildDishroomTrainings"))

    # buildLineTrainings includes ..._sharedTrainings(), so filter duplicates by source image.
    shared_images = {item["source_image"] for item in shared}
    line_only = [item for item in line if item["source_image"] not in shared_images]
    dishroom_only = [item for item in dishroom if item["source_image"] not in shared_images]

    payload = {
        "metadata": {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "source": str(DART_FILE.relative_to(ROOT)),
            "notes": "Cleaned 2-minute training extraction from source JPG transcriptions.",
        },
        "trainings": {
            "shared": shared,
            "line": line_only,
            "dishroom": dishroom_only,
        },
        "counts": {
            "shared": len(shared),
            "line": len(line_only),
            "dishroom": len(dishroom_only),
            "total": len(shared) + len(line_only) + len(dishroom_only),
        },
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"Wrote {OUT_JSON}")
    print(
        f"Counts -> shared: {len(shared)}, line: {len(line_only)}, dishroom: {len(dishroom_only)}"
    )


if __name__ == "__main__":
    main()
