#!/usr/bin/env python3
"""Build a cleaned structured OCR export from MTCDocuments artifacts."""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable


ROOT = Path("/Users/lajicpajam/Development/active/Apps/MTCafeteria")
OCR_TRAININGS = ROOT / "artifacts" / "ocr_trainings"
OCR_TRAININGS_ROT = ROOT / "artifacts" / "ocr_trainings_rot"
OCR_DOCS = ROOT / "artifacts" / "ocr_documents"
OUT_JSON = ROOT / "artifacts" / "ocr_structured_export.json"
OUT_MD = ROOT / "artifacts" / "ocr_structured_export_summary.md"


def _read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="ignore")


def _clean_lines(text: str) -> list[str]:
    def sanitize(line: str) -> str:
        line = (
            line.replace("“", '"')
            .replace("”", '"')
            .replace("’", "'")
            .replace("—", "-")
            .replace("–", "-")
        )
        line = re.sub(r"\s+", " ", line).strip()
        line = re.sub(r"^[|_`~.,;:]+", "", line).strip()
        line = re.sub(r"[|_`~]+$", "", line).strip()
        line = re.sub(r"\s+([.,;:!?])", r"\1", line)
        return line

    def looks_garbled(line: str) -> bool:
        if "2 minute training" in line.lower():
            return True
        alnum = re.sub(r"[^A-Za-z0-9]", "", line)
        if len(alnum) < 3:
            return True

        letters = len(re.findall(r"[A-Za-z]", line))
        if letters < 3:
            return True

        allowed = len(re.findall(r"""[A-Za-z0-9\s.,;:!?()'"\/&%-]""", line))
        non_allowed = max(0, len(line) - allowed)
        words = [w for w in line.split(" ") if w]
        one_letter = len([w for w in words if len(w) == 1])
        long_words = len([w for w in words if len(w) >= 4])

        if len(line) >= 10 and non_allowed / len(line) > 0.18:
            return True
        if len(words) >= 5 and one_letter / len(words) > 0.45:
            return True
        if len(line) >= 14 and long_words == 0:
            return True
        return False

    lines: list[str] = []
    prev = ""
    for raw in text.replace("\r", "\n").split("\n"):
        line = sanitize(raw)
        if not line:
            continue
        if looks_garbled(line):
            continue
        if line == prev:
            continue
        lines.append(line)
        prev = line
    return lines


def _title_guess(lines: Iterable[str], fallback: str) -> str:
    for line in lines:
        # Prefer lines with mostly letters and 2-8 words.
        words = line.split()
        if 2 <= len(words) <= 10 and re.search(r"[A-Za-z]{3,}", line):
            return line
    return fallback


def _num_key_from_name(name: str) -> int:
    m = re.search(r"(\d+)", name)
    return int(m.group(1)) if m else 0


@dataclass
class OCRItem:
    key: str
    source_file: str
    ocr_file: str
    title_guess: str
    chars_raw: int
    lines_clean_count: int
    text_clean: str
    lines_clean: list[str]


def _item_from_txt(key: str, source_file: str, txt_path: Path) -> OCRItem:
    raw = _read(txt_path)
    lines = _clean_lines(raw)
    return OCRItem(
        key=key,
        source_file=source_file,
        ocr_file=str(txt_path.relative_to(ROOT)).replace("\\", "/"),
        title_guess=_title_guess(lines[:10], fallback=key),
        chars_raw=len(raw),
        lines_clean_count=len(lines),
        text_clean="\n".join(lines),
        lines_clean=lines,
    )


def _collect_training_group(prefix: str, folder: str | None = None) -> list[OCRItem]:
    """
    Collect training OCR text for Shared/Line/Dishroom.
    Prefer canonical txt (non-psm11). For Line/Dishroom prefer subfolder txt.
    """
    items: list[OCRItem] = []

    if folder is not None:
        # Prefer rotated OCR outputs when available; they are more legible.
        source_root = OCR_TRAININGS_ROT if OCR_TRAININGS_ROT.exists() else OCR_TRAININGS
        source_paths = sorted((source_root / folder).glob(f"{prefix}*.txt"))
        for p in source_paths:
            stem = p.stem
            source = f"MTCDocuments/2MinuteTrainings/{folder}/{stem}.JPG"
            item = _item_from_txt(key=stem, source_file=source, txt_path=p)
            items.append(item)
    else:
        # SharedN.txt in root (skip .psm11); prefer rotated OCR outputs.
        source_root = OCR_TRAININGS_ROT if OCR_TRAININGS_ROT.exists() else OCR_TRAININGS
        source_paths = sorted(
            [
                p
                for p in source_root.glob(f"{prefix}*.txt")
                if not p.name.endswith(".psm11.txt")
            ],
            key=lambda p: _num_key_from_name(p.stem),
        )
        for p in source_paths:
            stem = p.stem
            source = f"MTCDocuments/2MinuteTrainings/{stem}.JPG"
            item = _item_from_txt(key=stem, source_file=source, txt_path=p)
            items.append(item)

    return items


def _collect_documents() -> dict:
    buckets = {
        "dishroom": [],
        "kitchen": [],
        "custodial": [],
        "misc": {
            "informational": [],
            "line_jobs": [],
            "lockers": [],
            "safety": [],
            "other": [],
        },
    }

    for p in sorted(OCR_DOCS.rglob("*.txt")):
        rel = p.relative_to(OCR_DOCS)
        parts = rel.parts
        key = p.stem
        rel_source = str(rel.with_suffix(".JPG")).replace("\\", "/")
        source = f"MTCDocuments/{rel_source}"
        item = _item_from_txt(key=key, source_file=source, txt_path=p)

        top = parts[0] if parts else ""
        if top == "Dishroom":
            buckets["dishroom"].append(asdict(item))
        elif top == "Kitchen":
            buckets["kitchen"].append(asdict(item))
        elif top == "Night Custodial":
            buckets["custodial"].append(asdict(item))
        elif top == "Misc":
            subgroup = parts[1] if len(parts) > 1 else "other"
            if subgroup == "Informational":
                buckets["misc"]["informational"].append(asdict(item))
            elif subgroup == "LineJobs":
                buckets["misc"]["line_jobs"].append(asdict(item))
            elif subgroup == "Lockers":
                buckets["misc"]["lockers"].append(asdict(item))
            elif subgroup == "Safety":
                buckets["misc"]["safety"].append(asdict(item))
            else:
                buckets["misc"]["other"].append(asdict(item))
        else:
            buckets["misc"]["other"].append(asdict(item))

    return buckets


def _summary_markdown(payload: dict) -> str:
    t = payload["trainings"]
    d = payload["documents"]
    return "\n".join(
        [
            "# OCR Structured Export",
            "",
            f"- Generated: `{payload['metadata']['generated_at']}`",
            f"- Source: `{payload['metadata']['source_root']}`",
            "",
            "## Trainings",
            f"- Shared: `{len(t['shared'])}`",
            f"- Line: `{len(t['line'])}`",
            f"- Dishroom: `{len(t['dishroom'])}`",
            "",
            "## Other Documents",
            f"- Dishroom: `{len(d['dishroom'])}`",
            f"- Kitchen: `{len(d['kitchen'])}`",
            f"- Custodial: `{len(d['custodial'])}`",
            f"- Misc/Informational: `{len(d['misc']['informational'])}`",
            f"- Misc/LineJobs: `{len(d['misc']['line_jobs'])}`",
            f"- Misc/Lockers: `{len(d['misc']['lockers'])}`",
            f"- Misc/Safety: `{len(d['misc']['safety'])}`",
            f"- Misc/Other: `{len(d['misc']['other'])}`",
            "",
            "## Output Files",
            f"- JSON: `{OUT_JSON.relative_to(ROOT)}`",
            f"- Summary: `{OUT_MD.relative_to(ROOT)}`",
            "",
        ]
    )


def main() -> None:
    trainings = {
        "shared": [asdict(i) for i in _collect_training_group("Shared")],
        "line": [asdict(i) for i in _collect_training_group("Line", folder="Line")],
        "dishroom": [
            asdict(i) for i in _collect_training_group("Dishroom", folder="Dishroom")
        ],
    }
    documents = _collect_documents()

    payload = {
        "metadata": {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "source_root": str((ROOT / "frontend_flutter" / "MTCDocuments")),
            "notes": "Data extraction only. No app logic changes.",
        },
        "trainings": trainings,
        "documents": documents,
    }

    OUT_JSON.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    OUT_MD.write_text(_summary_markdown(payload), encoding="utf-8")
    print(f"Wrote {OUT_JSON}")
    print(f"Wrote {OUT_MD}")


if __name__ == "__main__":
    main()

