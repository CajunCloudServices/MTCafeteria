#!/usr/bin/env python3
"""High-quality OCR extraction for non-training MTCDocuments folders."""

from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path

import cv2
import pytesseract

ROOT = Path("/Users/lajicpajam/Development/active/Apps/MTCafeteria")
DOCS_ROOT = ROOT / "frontend_flutter" / "MTCDocuments"
OUT_ROOT = ROOT / "artifacts" / "ocr_documents_clean"
OUT_JSON = ROOT / "artifacts" / "mtc_documents_non_training_extracted.json"
OUT_MD = ROOT / "artifacts" / "mtc_documents_non_training_extracted_summary.md"
TARGET_TOP_FOLDERS = ["Dishroom", "Kitchen", "Night Custodial", "Misc"]


@dataclass
class ExtractionItem:
    key: str
    source_image: str
    folder: str
    subfolder: str
    quality_score: float
    lines_count: int
    cleaned_text: str
    cleaned_lines: list[str]
    review_required: bool


def sanitize_line(line: str) -> str:
    value = (
        line.replace("“", '"')
        .replace("”", '"')
        .replace("’", "'")
        .replace("—", "-")
        .replace("–", "-")
        .replace("•", "- ")
        .replace("\u00a0", " ")
    )
    value = re.sub(r"\s+", " ", value).strip()
    value = re.sub(r"^[|_`~.,;:]+", "", value).strip()
    value = re.sub(r"[|_`~]+$", "", value).strip()
    value = re.sub(r"\s+([.,;:!?])", r"\1", value)
    value = re.sub(r"\s+[-=+_]{1,3}$", "", value).strip()
    return value


def looks_like_noise(line: str) -> bool:
    if not line:
        return True
    alnum = re.sub(r"[^A-Za-z0-9]", "", line)
    if len(alnum) < 3:
        return True

    letter_count = len(re.findall(r"[A-Za-z]", line))
    words = [w for w in line.split(" ") if w]
    long_words = [w for w in words if len(w) >= 4]
    one_char_words = [w for w in words if len(w) == 1]

    if letter_count < 3:
        return True
    if len(line) >= 14 and not long_words:
        return True
    if len(words) >= 6 and len(one_char_words) / max(len(words), 1) > 0.5:
        return True
    return False


def quality_score(text: str) -> float:
    words = re.findall(r"[A-Za-z]{3,}", text.lower())
    if not words:
        return 0.0
    vowel_words = [w for w in words if re.search(r"[aeiou]", w)]
    unique_words = len(set(words))
    avg_len = sum(len(w) for w in words) / len(words)
    return (
        0.55 * (len(vowel_words) / len(words))
        + 0.25 * min(unique_words / 120, 1.0)
        + 0.20 * min(avg_len / 7.5, 1.0)
    )


def run_ocr(image, config: str, timeout_sec: int = 12) -> str:
    try:
        return pytesseract.image_to_string(image, config=config, timeout=timeout_sec)
    except RuntimeError:
        return ""


def orient(image, degrees: int):
    if degrees == 0:
        return image
    if degrees == 90:
        return cv2.rotate(image, cv2.ROTATE_90_CLOCKWISE)
    if degrees == 180:
        return cv2.rotate(image, cv2.ROTATE_180)
    if degrees == 270:
        return cv2.rotate(image, cv2.ROTATE_90_COUNTERCLOCKWISE)
    return image


def ocr_candidates(img):
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    up = cv2.resize(gray, None, fx=2.0, fy=2.0, interpolation=cv2.INTER_CUBIC)
    blur = cv2.GaussianBlur(up, (3, 3), 0)
    adp = cv2.adaptiveThreshold(
        blur,
        255,
        cv2.ADAPTIVE_THRESH_GAUSSIAN_C,
        cv2.THRESH_BINARY,
        41,
        11,
    )
    otsu = cv2.threshold(up, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    denoise = cv2.fastNlMeansDenoising(up, None, h=12, templateWindowSize=7, searchWindowSize=21)

    variants = [up, adp, otsu, denoise]
    configs = ["--oem 3 --psm 6", "--oem 3 --psm 11"]
    texts: list[str] = []
    for v in variants:
        for cfg in configs:
            texts.append(run_ocr(v, cfg))
    return texts


def best_ocr_text(image_path: Path) -> str:
    img = cv2.imread(str(image_path))
    if img is None:
        return ""

    # Fast orientation sweep first.
    orient_scores: list[tuple[int, float]] = []
    for deg in (0, 90, 180, 270):
        oriented = orient(img, deg)
        gray = cv2.cvtColor(oriented, cv2.COLOR_BGR2GRAY)
        quick = run_ocr(gray, "--oem 3 --psm 6", timeout_sec=8)
        orient_scores.append((deg, quality_score(quick)))
    orient_scores.sort(key=lambda t: t[1], reverse=True)

    best_text = ""
    best_score = -1.0
    candidate_orients = [orient_scores[0][0]]
    if orient_scores[0][1] < 0.45:
        candidate_orients.append(orient_scores[1][0])

    for deg in candidate_orients:
        oriented = orient(img, deg)
        for text in ocr_candidates(oriented):
            score = quality_score(text)
            if score > best_score:
                best_score = score
                best_text = text

    # Rare fallback for tough pages.
    if best_score < 0.35:
        for deg in (0, 90, 180, 270):
            oriented = orient(img, deg)
            gray = cv2.cvtColor(oriented, cv2.COLOR_BGR2GRAY)
            up = cv2.resize(gray, None, fx=2.0, fy=2.0, interpolation=cv2.INTER_CUBIC)
            text = run_ocr(up, "--oem 3 --psm 6")
            score = quality_score(text)
            if score > best_score:
                best_score = score
                best_text = text

    return best_text


def clean_text(raw_text: str) -> tuple[str, list[str]]:
    lines: list[str] = []
    seen = set()
    for raw in raw_text.replace("\r", "\n").split("\n"):
        line = sanitize_line(raw)
        if looks_like_noise(line):
            continue
        key = line.lower()
        if key in seen:
            continue
        seen.add(key)
        lines.append(line)
    return "\n".join(lines), lines


def is_review_required(lines: list[str], score: float) -> bool:
    if score < 0.43:
        return True
    if len(lines) < 6:
        return True
    short_lines = [ln for ln in lines if len(ln) < 12]
    if len(short_lines) / len(lines) > 0.45:
        return True
    return False


def collect_images() -> list[Path]:
    images: list[Path] = []
    for top in TARGET_TOP_FOLDERS:
        top_path = DOCS_ROOT / top
        if not top_path.exists():
            continue
        images.extend(sorted(top_path.rglob("*.JPG")))
    return images


def relative_source(path: Path) -> str:
    return str(path.relative_to(DOCS_ROOT)).replace("\\", "/")


def run() -> None:
    OUT_ROOT.mkdir(parents=True, exist_ok=True)
    images = collect_images()

    grouped: dict[str, list[dict]] = {
        "Dishroom": [],
        "Kitchen": [],
        "Night Custodial": [],
        "Misc": [],
    }
    review = []

    for image in images:
        rel = relative_source(image)
        parts = rel.split("/")
        top = parts[0]
        sub = parts[1] if len(parts) > 2 else ("(root)" if len(parts) == 2 else "")
        key = image.stem
        print(f"[{len(grouped['Dishroom']) + len(grouped['Kitchen']) + len(grouped['Night Custodial']) + len(grouped['Misc']) + 1}/{len(images)}] {rel}")

        raw = best_ocr_text(image)
        cleaned_text, cleaned_lines = clean_text(raw)
        score = quality_score(cleaned_text)
        needs_review = is_review_required(cleaned_lines, score)

        out_txt = OUT_ROOT / f"{rel.rsplit('.', 1)[0]}.txt"
        out_txt.parent.mkdir(parents=True, exist_ok=True)
        out_txt.write_text(cleaned_text, encoding="utf-8")

        item = ExtractionItem(
            key=key,
            source_image=f"MTCDocuments/{rel}",
            folder=top,
            subfolder=sub,
            quality_score=round(score, 4),
            lines_count=len(cleaned_lines),
            cleaned_text=cleaned_text,
            cleaned_lines=cleaned_lines,
            review_required=needs_review,
        )
        grouped[top].append(asdict(item))
        if needs_review:
            review.append((top, rel, score, len(cleaned_lines)))

    payload = {
        "metadata": {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "source_root": str(DOCS_ROOT),
            "folders": TARGET_TOP_FOLDERS,
            "notes": "Extraction only. No app code changes.",
        },
        "documents": grouped,
    }
    OUT_JSON.write_text(json.dumps(payload, indent=2), encoding="utf-8")

    md = [
        "# Non-Training MTCDocuments Extraction",
        "",
        f"- Generated: `{payload['metadata']['generated_at']}`",
        f"- Source root: `{DOCS_ROOT}`",
        f"- Output JSON: `{OUT_JSON.relative_to(ROOT)}`",
        f"- Output TXT root: `{OUT_ROOT.relative_to(ROOT)}`",
        "",
        "## Counts",
        f"- Dishroom: `{len(grouped['Dishroom'])}`",
        f"- Kitchen: `{len(grouped['Kitchen'])}`",
        f"- Night Custodial: `{len(grouped['Night Custodial'])}`",
        f"- Misc: `{len(grouped['Misc'])}`",
        "",
    ]
    if review:
        md.append("## Needs Manual Review")
        for top, rel, score, lines_count in review:
            md.append(
                f"- `{top}` / `{rel}` (score `{score:.3f}`, lines `{lines_count}`)"
            )
    else:
        md.append("## Needs Manual Review")
        md.append("- None")

    OUT_MD.write_text("\n".join(md) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_JSON}")
    print(f"Wrote {OUT_MD}")
    print(
        f"Counts -> Dishroom: {len(grouped['Dishroom'])}, Kitchen: {len(grouped['Kitchen'])}, "
        f"Night Custodial: {len(grouped['Night Custodial'])}, Misc: {len(grouped['Misc'])}, "
        f"Review flags: {len(review)}"
    )


if __name__ == "__main__":
    run()
