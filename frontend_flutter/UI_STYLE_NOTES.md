# UI Style Notes

This app should feel like one system, not a collection of one-off screens.

## Geometry

- Use the task-flow cards as the baseline.
- Outer cards, shells, and major panels use a `10` radius.
- Inputs use a `6` radius.
- Buttons use an `8` radius.
- Chips and small badges use a `6` radius.
- Modal/detail sheets use a `16` radius.
- Tiny accent bars and drag handles can stay tighter at `3`.

## Where Tokens Live

- Shared tokens are in [`/Users/lajicpajam/Development/active/Apps/MTCafeteria/frontend_flutter/lib/theme/app_ui_tokens.dart`](/Users/lajicpajam/Development/active/Apps/MTCafeteria/frontend_flutter/lib/theme/app_ui_tokens.dart)
- Prefer those constants over sprinkling raw `8`, `10`, `14`, `18`, or `22` values around the app.

## Card Rules

- Card-like surfaces that do the same job should have the same radius.
- Do not make dashboard, reference, announcement, report, and support shells visually different without a reason.
- Avoid oversized rounding on outer containers. The app should feel clean, not pill-shaped.
- Avoid decorative nested wrappers when one panel is enough.

## Copy Rules

- Remove helper copy that states the obvious.
- Titles should do the work. Extra explanatory text should only exist when it adds real operational value.
- Keep mobile layouts concise and readable first.

## Guides Rules

- Top-level `Section` dropdown stays outside the blue content container.
- Section-specific dropdown stays inside the blue content container.
- Do not repeat the selected section name inside the content area.
- Do not wrap already-carded content in another decorative card.

## When Adding New UI

Before adding a new custom container, check whether it is really:

1. an outer shell
2. an inner content card
3. a chip/badge
4. a sheet/dialog surface

Then use the existing token for that surface type instead of inventing a new radius.
