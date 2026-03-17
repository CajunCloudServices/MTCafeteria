# MTC Dining Feature Prioritization For Pilot

This file ranks the app's current features by pilot suitability.

Ranking criteria:
- `Value`: how useful the feature is during a real shift
- `Effort`: how much implementation/support/maintenance burden it adds
- `Privacy/Security`: how much identity, personnel, or sensitive operational data it touches

Scale:
- `Value`: High / Medium / Low
- `Effort`: Low / Medium / High
- `Privacy/Security`: Low / Medium / High

## Recommendation Summary

The safest pilot is a stripped-down operational tool built around:
- line workflow checklists
- supervisor checkoff
- references
- two-minute trainings
- dining map

These are the best first pilot features because they are operationally useful and do not require storing or exposing much personal information.

Features that should stay out of the first pilot:
- login
- points / discipline workflows
- manager approval flows
- profile
- daily shift reports sent to leadership

Those features involve personal identity, personnel/disciplinary information, or more formal process ownership.

## Ranked Features

| Rank | Feature | Current App Area | Value | Effort | Privacy/Security | Pilot? | Reason |
|---|---|---|---|---|---|---|---|
| 1 | Line worker task flow | Dashboard > Workflow > Line > Employee/Line Worker | High | Low | Low | Yes | Core operational need. Helps workers know what to do before, during, and after shift without storing sensitive data. |
| 2 | Supervisor job checkoff | Dashboard > Workflow > Line > Supervisor > Jobs/Secondaries/Deep Clean | High | Medium | Low | Yes | High shift value. Operational coordination only. No personal data required if pilot mode skips identity. |
| 3 | Reference sheets | Dashboard > References | High | Low | Low | Yes | Very safe. Pure view-only information. Immediate training value. |
| 4 | Find an item / locker lookup | References > Find an Item | High | Low | Low | Yes | Fast lookup tool with almost no security concern. |
| 5 | Condiments rotation reference | References > Condiments Rotation | High | Low | Low | Yes | Useful and low-risk. Pure operational reference. |
| 6 | Line secondary + checkoff reference | References > Line Secondary + Checkoff | High | Low | Low | Yes | Good support for shift close. No identity required. |
| 7 | Dining map | References > Dining Map | Medium | Low | Low | Yes | Good onboarding/support feature. Minimal risk. |
| 8 | Two-minute trainings | Dashboard hub > Two-minute Trainings | Medium | Low | Low | Yes | Useful training support. Low privacy risk if not tied to individual completion history. |
| 9 | Aloha + Choices reference | References > Aloha + Choices | Medium | Low | Low | Yes | Useful operational context and low risk. |
| 10 | Kitchen jobs references/recipes | Dashboard > Workflow > Kitchen Jobs | Medium | Medium | Low | Yes | Good for support and consistency. Still low-risk if used only as reference. |
| 11 | Pilot mode | App profile / config mode | High | Low | Low | Yes | Important for safe testing because it removes login friction and avoids exposing unnecessary identity features. |
| 12 | Lead trainer task flow | Dashboard > Workflow > Line > Lead Trainer | Medium | Medium | Low | Maybe | Operationally useful, but more complex than worker/supervisor flows. Fine for pilot if stable. |
| 13 | Student manager landing-page announcements | Home + manager portal | Medium | Medium | Low | Maybe | Useful, but requires some content ownership and moderation. Still not very sensitive if limited to general announcements. |
| 14 | Dishroom worker flow | Dashboard > Workflow > Dishroom | Medium | Medium | Low | Later | Not inherently sensitive, but you said it is not finished. Not a first-pilot candidate yet. |
| 15 | Dishroom lead trainer flow | Dashboard > Workflow > Dishroom Lead Trainer | Medium | Medium | Low | Later | Same issue as dishroom: low privacy risk, but unfinished and lower immediate priority. |
| 16 | Night custodial flow | Dashboard > Workflow > Night Custodial | Medium | Medium | Low | Later | Low privacy risk, but unfinished and not part of the immediate pilot. |
| 17 | Daily shift report drafting | Supervisor flow > Daily Shift Report | Medium | High | Medium | Later | Operationally useful, but more process-heavy and stores shift-specific submitted records. Better after core workflow testing. |
| 18 | Leadership daily shift report viewing | Dashboard > Daily Shift Reports | Medium | Medium | Medium | Later | Useful to leadership, but introduces stored reporting records and visibility rules. |
| 19 | Home announcements editing | Manager portal | Medium | Medium | Medium | Later | Not highly sensitive, but still introduces permissioned content editing and governance questions. |
| 20 | Role selection by actual user capability | Dashboard routing / auth-based gating | Medium | Medium | Medium | Later | Fine in a production tool, but for pilot mode it adds complexity without much benefit. |
| 21 | Login / JWT auth | Auth flow | Low | Medium | High | No | Not needed for first pilot if users are just testing flows. Adds identity/security concerns immediately. |
| 22 | Profile tab | Profile | Low | Low | Medium | No | Low operational value for first pilot. Mostly identity-adjacent surface area. |
| 23 | Points assignment | Dashboard / Student Manager Portal | Medium | High | High | No | This is disciplinary/personnel-related and absolutely raises privacy/governance concerns. |
| 24 | Point approval workflow | Manager review flow | Medium | High | High | No | Same issue, plus formal approval process and audit expectations. |
| 25 | Point acknowledgment by employee initials | Points confirmation flow | Medium | High | High | No | Explicitly identity-related and sensitive. Not appropriate for early pilot testing. |
| 26 | Stored personal point history | Backend points data | Medium | High | High | No | Highest governance/privacy burden of the current feature set. |

## Best Pilot Scope

If the goal is to test the app during real shifts without raising concern about identity, privacy, or institutional approval, the cleanest pilot scope is:

1. `Home`
   - announcements view only

2. `Dashboard`
   - line workflow
   - supervisor checkoff
   - lead trainer flow if stable enough
   - kitchen jobs reference flow

3. `References`
   - line jobs
   - find an item
   - condiments rotation
   - line secondary + checkoff
   - dining map
   - aloha + choices

4. `Two-minute trainings`
   - view-only
   - rotating daily training

5. `Pilot mode`
   - no login
   - no profile
   - no points
   - no manager-only sensitive workflows

## Features To Keep Out Of Pilot

These features are the most likely to trigger concern from leadership, IT, HR-like stakeholders, or anyone worried about personnel handling:

- login tied to real identities
- profile tied to a specific worker
- points / discipline workflows
- approvals and acknowledgments
- personally attributable reporting history
- anything that looks like employee discipline tracking

## Practical Rollout Order

If you want a staged rollout, this is the order that makes the most sense:

1. `Pilot V1`
   - line worker tasks
   - supervisor checkoff
   - references
   - two-minute trainings
   - dining map

2. `Pilot V2`
   - announcements editing
   - lead trainer workflow
   - kitchen jobs and dishroom once stable

3. `Post-pilot / official review`
   - login
   - daily shift reports
   - role-based stored history
   - points and approvals only if institutionally approved

## Recommendation

If the goal is real-world shift testing soon, the right move is to treat this app primarily as:

- a shift workflow guide
- a supervisor checkoff tool
- a training/reference tool

and not as:

- a personnel tracking system
- a disciplinary system
- an identity-managed internal platform

That will give you the most useful pilot with the least institutional friction.
