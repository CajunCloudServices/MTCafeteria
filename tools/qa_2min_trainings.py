#!/usr/bin/env python3
"""Run image-by-image QA against cleaned 2-minute training transcriptions."""

from __future__ import annotations

import json
import re
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import cv2
import pytesseract

ROOT = Path("/Users/lajicpajam/Development/active/Apps/MTCafeteria")
TRAININGS_JSON = ROOT / "artifacts/2minute_trainings_clean.json"
IMAGES_ROOT = ROOT / "frontend_flutter/MTCDocuments/2MinuteTrainings"
OUT_JSON = ROOT / "artifacts/2minute_trainings_qa_report.json"
OUT_MD = ROOT / "artifacts/2minute_trainings_qa_report.md"


STOPWORDS = {
    "the",
    "and",
    "for",
    "with",
    "that",
    "this",
    "from",
    "your",
    "into",
    "they",
    "them",
    "when",
    "what",
    "where",
    "have",
    "will",
    "should",
    "then",
    "than",
    "only",
    "each",
    "also",
    "over",
    "must",
    "very",
}


@dataclass
class QaResult:
    track: str
    title: str
    source_image: str
    status: str
    coverage: float
    title_match: float
    lines_checked: int
    lines_matched: int
    weak_lines: list[str]


def image_path(source_image: str) -> Path:
    if source_image.startswith("Shared"):
        return IMAGES_ROOT / source_image
    if source_image.startswith("Line"):
        return IMAGES_ROOT / "Line" / source_image
    if source_image.startswith("Dishroom"):
        return IMAGES_ROOT / "Dishroom" / source_image
    raise ValueError(f"Unknown source image convention: {source_image}")


def normalize_tokens(text: str, min_len: int = 4) -> list[str]:
    words = re.findall(r"[A-Za-z0-9']+", text.lower())
    return [w for w in words if len(w) >= min_len and w not in STOPWORDS]


def ocr_text(path: Path) -> str:
    img = cv2.imread(str(path))
    if img is None:
        return ""
    h, w = img.shape[:2]
    # Slight inner crop to remove binder/background noise.
    crop = img[int(h * 0.07) : int(h * 0.96), int(w * 0.08) : int(w * 0.96)]
    gray = cv2.cvtColor(crop, cv2.COLOR_BGR2GRAY)
    up = cv2.resize(gray, None, fx=2.0, fy=2.0, interpolation=cv2.INTER_CUBIC)

    blur = cv2.GaussianBlur(up, (3, 3), 0)
    th = cv2.adaptiveThreshold(
        blur,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        41,
        11,
    )
    th2 = cv2.threshold(up, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]

    txt1 = pytesseract.image_to_string(up, config="--oem 3 --psm 6")
    txt2 = pytesseract.image_to_string(th, config="--oem 3 --psm 6")
    txt3 = pytesseract.image_to_string(th2, config="--oem 3 --psm 11")
    return "\n".join([txt1, txt2, txt3])


def line_score(line: str, ocr_token_set: set[str]) -> float:
    clean = line.lstrip("- ").strip()
    if not clean:
        return 1.0
    tokens = normalize_tokens(clean, min_len=4)
    if not tokens:
        return 1.0
    hit = sum(1 for t in tokens if t in ocr_token_set)
    return hit / len(tokens)


def evaluate_entry(track: str, item: dict) -> QaResult:
    img_path = image_path(item["source_image"])
    ocr = ocr_text(img_path)
    ocr_tokens = set(normalize_tokens(ocr, min_len=3))

    lines = [ln.strip() for ln in item.get("lines", []) if ln.strip()]
    body_lines = [
        ln
        for ln in lines
        if not ln.lower().startswith("objective:")
        and not ln.lower().startswith("teaching idea:")
        and not ln.endswith(":")
    ]
    checked = 0
    matched = 0
    weak: list[str] = []
    for ln in body_lines:
        score = line_score(ln, ocr_tokens)
        checked += 1
        if score >= 0.45:
            matched += 1
        elif len(weak) < 4:
            weak.append(ln)

    title_tokens = normalize_tokens(item["title"], min_len=4)
    if title_tokens:
        title_hit = sum(1 for t in title_tokens if t in ocr_tokens)
        title_match = title_hit / len(title_tokens)
    else:
        title_match = 1.0

    coverage = (matched / checked) if checked else 1.0
    status = "OK" if coverage >= 0.62 and title_match >= 0.5 else "needs_tweak"
    return QaResult(
        track=track,
        title=item["title"],
        source_image=item["source_image"],
        status=status,
        coverage=coverage,
        title_match=title_match,
        lines_checked=checked,
        lines_matched=matched,
        weak_lines=weak,
    )


def main() -> None:
    payload = json.loads(TRAININGS_JSON.read_text(encoding="utf-8"))
    results: list[QaResult] = []
    for track in ("shared", "line", "dishroom"):
        for item in payload["trainings"][track]:
            results.append(evaluate_entry(track, item))

    by_track = {"shared": [], "line": [], "dishroom": []}
    for r in results:
        by_track[r.track].append(r)

    report = {
        "metadata": {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "method": "Multi-pass OCR against source JPGs with token-overlap line coverage.",
            "source_json": str(TRAININGS_JSON.relative_to(ROOT)),
        },
        "summary": {
            "total": len(results),
            "ok": sum(1 for r in results if r.status == "OK"),
            "needs_tweak": sum(1 for r in results if r.status != "OK"),
        },
        "results": [r.__dict__ for r in results],
    }
    OUT_JSON.write_text(json.dumps(report, indent=2), encoding="utf-8")

    lines = [
        "# 2-Minute Trainings QA Report",
        "",
        f"- Generated: `{report['metadata']['generated_at']}`",
        f"- Total trainings checked: `{report['summary']['total']}`",
        f"- `OK`: `{report['summary']['ok']}`",
        f"- `needs_tweak`: `{report['summary']['needs_tweak']}`",
        "",
        "## Checklist",
        "",
        "| Track | Title | Image | Status | Coverage | Title Match |",
        "|---|---|---|---:|---:|---:|",
    ]
    for r in results:
        lines.append(
            f"| {r.track} | {r.title} | {r.source_image} | {r.status} | {r.coverage:.2f} | {r.title_match:.2f} |"
        )

    lines.append("")
    lines.append("## Needs Tweak Details")
    lines.append("")
    tweak_items = [r for r in results if r.status != "OK"]
    if not tweak_items:
        lines.append("- None")
    else:
        for r in tweak_items:
            lines.append(f"- `{r.track}` / `{r.title}` (`{r.source_image}`)")
            if r.weak_lines:
                for ln in r.weak_lines:
                    lines.append(f"  - Weak match: `{ln}`")
            else:
                lines.append("  - Weak match: (none captured)")
    lines.append("")
    OUT_MD.write_text("\n".join(lines), encoding="utf-8")

    print(f"Wrote {OUT_JSON}")
    print(f"Wrote {OUT_MD}")
    print(
        f"Summary -> OK: {report['summary']['ok']}, needs_tweak: {report['summary']['needs_tweak']}, total: {report['summary']['total']}"
    )


if __name__ == "__main__":
    main()
