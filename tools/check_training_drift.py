#!/usr/bin/env python3
"""Check for training source-image drift between cleaned JSON and Dart corpus."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


ROOT = Path("/Users/lajicpajam/Development/active/Apps/MTCafeteria")
CLEANED_JSON = ROOT / "artifacts/mtcdocuments_vision_trainings_cleaned.json"
DART_FILE = ROOT / "frontend_flutter/lib/pages/training/training_text_data.dart"


def is_runtime_training_image(name: str) -> bool:
    return bool(re.match(r"^(Shared|Line|Dishroom)\d+\.JPG$", name))


def cleaned_images() -> set[str]:
    payload = json.loads(CLEANED_JSON.read_text(encoding="utf-8"))
    images: set[str] = set()
    for item in payload:
        rel = item.get("file", "")
        if not rel.startswith("2MinuteTrainings/"):
            continue
        name = Path(rel).name
        if is_runtime_training_image(name):
            images.add(name)
    return images


def dart_images() -> set[str]:
    text = DART_FILE.read_text(encoding="utf-8")
    return {
        name
        for name in re.findall(r"sourceImage:\s*'([^']+\.JPG)'", text)
        if is_runtime_training_image(name)
    }


def main() -> int:
    cleaned = cleaned_images()
    dart = dart_images()

    missing_in_dart = sorted(cleaned - dart)
    missing_in_cleaned = sorted(dart - cleaned)

    print(f"Cleaned JSON images: {len(cleaned)}")
    print(f"Dart corpus images: {len(dart)}")

    if not missing_in_dart and not missing_in_cleaned:
        print("No source-image drift detected.")
        return 0

    if missing_in_dart:
        print("\nPresent in cleaned JSON but missing from Dart corpus:")
        for name in missing_in_dart:
            print(f"- {name}")

    if missing_in_cleaned:
        print("\nPresent in Dart corpus but missing from cleaned JSON:")
        for name in missing_in_cleaned:
            print(f"- {name}")

    return 1


if __name__ == "__main__":
    sys.exit(main())
