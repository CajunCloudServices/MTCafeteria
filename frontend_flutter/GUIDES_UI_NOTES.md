# Guides UI Notes

Rules for grouped guide sections (`Line`, `Kitchen`, `Dishroom`, `Night Custodial`, `Safety`, `General Information`):

- Keep the top-level `Section` dropdown outside the blue content container.
- Put the section-specific dropdown inside the blue content container.
- Do not repeat the selected section name inside the content area.
- After the top-level `Section` dropdown is set, the next view should start with the subsection dropdown or the actual content.
- Avoid extra wrapper panels around already-carded guide content.
- Favor width for the guide text instead of decorative nesting.
- Avoid helper copy that explains obvious actions.

Examples:

- Good: `Section: Dishroom` outside, then one blue container with `Dishroom section` dropdown and the guide card.
- Bad: `Section: Dishroom` inside the blue container, or another container titled `Dishroom`, or a second blue wrapper around the actual guide card.
