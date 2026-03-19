#!/usr/bin/env python3
from __future__ import annotations

import csv
import math
import re
import textwrap
from pathlib import Path

import matplotlib.pyplot as plt


ROOT = Path("/Users/lajicpajam/Development/active/Apps/MTCafeteria")
CSV_PATH = ROOT / "PILOT_FEATURE_RANKING.csv"
OUT_PNG = ROOT / "artifacts" / "pilot_feature_ranking_visual.png"
OUT_SVG = ROOT / "artifacts" / "pilot_feature_ranking_visual.svg"


VALUE_MAP = {"Low": 1, "Medium": 2, "High": 3}
EFFORT_MAP = {"Low": 1, "Medium": 2, "High": 3}
PRIVACY_COLORS = {
    "Low": "#2D7A55",
    "Medium": "#AF8B00",
    "High": "#B04646",
}


def parse_money_to_k(text: str) -> float:
    cleaned = text.strip()
    if cleaned in {"Indirect", "Indirect / rollout savings", "Indirect / hard to quantify"}:
        return 0.3
    if cleaned in {"Minimal", "No meaningful direct savings"}:
        return 0.05
    numbers = [float(match) for match in re.findall(r"(\d+(?:\.\d+)?)k", cleaned)]
    if not numbers:
        return 0.0
    if len(numbers) == 1:
        return numbers[0]
    return sum(numbers) / len(numbers)


def short_label(label: str) -> str:
    return "\n".join(textwrap.wrap(label, width=18))


def load_rows() -> list[dict[str, str]]:
    with CSV_PATH.open(newline="") as f:
        return list(csv.DictReader(f))


def build_figure(rows: list[dict[str, str]]) -> None:
    rows = sorted(rows, key=lambda row: int(row["rank"]))
    for row in rows:
        row["rank_num"] = int(row["rank"])
        row["money_k"] = parse_money_to_k(row["estimated_money_savings"])
        row["value_num"] = VALUE_MAP[row["value"]]
        row["effort_num"] = EFFORT_MAP[row["implementation_effort"]]
        row["essentiality_num"] = VALUE_MAP[row["pilot_essentiality"]]
        row["bubble_size"] = 250 + (row["value_num"] * 120) + (row["essentiality_num"] * 120)

    fig = plt.figure(figsize=(11.5, 12), facecolor="white")
    grid = fig.add_gridspec(2, 1, height_ratios=[1, 1.15], hspace=0.32)

    ax_scatter = fig.add_subplot(grid[0, 0])
    ax_bars = fig.add_subplot(grid[1, 0])

    # Scatter: effort vs. annual savings. Use rank numbers instead of long labels
    # to keep the slide readable and avoid overlapping annotation text.
    for row in rows:
        ax_scatter.scatter(
            row["effort_num"],
            row["money_k"],
            s=row["bubble_size"],
            color=PRIVACY_COLORS[row["privacy_security"]],
            alpha=0.82,
            edgecolors="white",
            linewidths=1.5,
            zorder=3,
        )
        ax_scatter.text(
            row["effort_num"],
            row["money_k"],
            str(row["rank_num"]),
            ha="center",
            va="center",
            fontsize=11,
            fontweight="bold",
            color="white",
            zorder=4,
        )

    ax_scatter.set_title("Pilot Features: Savings vs. Effort", fontsize=16, fontweight="bold", color="#123A65")
    ax_scatter.set_xlabel("Implementation Effort", fontsize=11)
    ax_scatter.set_ylabel("Estimated Annual Savings ($k)", fontsize=11)
    ax_scatter.set_xticks([1, 2, 3], ["Low", "Medium", "High"])
    ax_scatter.grid(axis="y", color="#D9E4F2", linewidth=1)
    ax_scatter.grid(axis="x", color="#EEF4FB", linewidth=1)
    ax_scatter.set_axisbelow(True)
    ax_scatter.spines[["top", "right"]].set_visible(False)
    ax_scatter.set_ylim(bottom=0)
    ax_scatter.set_xlim(0.7, 3.3)

    legend_handles = [
        plt.Line2D([0], [0], marker="o", color="w", label=label, markerfacecolor=color, markersize=10)
        for label, color in PRIVACY_COLORS.items()
    ]
    ax_scatter.legend(
        handles=legend_handles,
        title="Privacy / Security",
        frameon=False,
        loc="upper left",
    )

    ax_scatter.text(
        1.0,
        -0.18,
        "Numbers match the ranked list below.",
        transform=ax_scatter.transAxes,
        ha="right",
        va="top",
        fontsize=10,
        color="#355C84",
    )

    # Bars: quick ranking by annual dollar savings.
    bar_rows = sorted(rows, key=lambda row: row["money_k"], reverse=True)
    bar_labels = [f"{row['rank']}. {row['feature']}" for row in bar_rows]
    bar_values = [row["money_k"] for row in bar_rows]
    bar_colors = [PRIVACY_COLORS[row["privacy_security"]] for row in bar_rows]

    ax_bars.barh(bar_labels, bar_values, color=bar_colors, alpha=0.9)
    ax_bars.invert_yaxis()
    ax_bars.set_title("Estimated Annual Savings by Feature", fontsize=16, fontweight="bold", color="#123A65")
    ax_bars.set_xlabel("Estimated Annual Savings ($k)", fontsize=11)
    ax_bars.grid(axis="x", color="#D9E4F2", linewidth=1)
    ax_bars.set_axisbelow(True)
    ax_bars.spines[["top", "right"]].set_visible(False)

    for i, row in enumerate(bar_rows):
        ax_bars.text(
            row["money_k"] + 0.15,
            i,
            row["estimated_money_savings"],
            va="center",
            fontsize=9,
            color="#17324D",
        )

    fig.suptitle(
        "MTC Dining Pilot Feature Ranking",
        fontsize=22,
        fontweight="bold",
        color="#103760",
        y=0.98,
    )
    fig.text(
        0.5,
        0.02,
        "Bubble size reflects combined value and pilot essentiality. Colors show privacy/security burden.",
        ha="center",
        fontsize=10,
        color="#355C84",
    )

    OUT_PNG.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(OUT_PNG, dpi=220, bbox_inches="tight")
    fig.savefig(OUT_SVG, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    rows = load_rows()
    build_figure(rows)
    print(f"Saved {OUT_PNG}")
    print(f"Saved {OUT_SVG}")


if __name__ == "__main__":
    main()
