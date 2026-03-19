# MTC Dining Pilot Feature Prioritization

This file ranks the app's current features by pilot essentiality first, while also factoring in value, implementation effort, privacy/security burden, and likely time savings.

The intent is:
- keep the list ordered from most pilot-essential to least
- prefer high-value, lower-effort features near the top
- still recognize that some heavy or sensitive features, especially points, are very valuable even if they are not the best first pilot bets

Ranking criteria:
- `Pilot Essentiality`: how important the feature is to making the pilot actually useful
- `Value`: how useful the feature is during real operations
- `Implementation Effort`: how much implementation/support/maintenance burden it adds
- `Privacy/Security`: how much identity, personnel, or sensitive operational data it touches
- `Potential Time Savings`: rough estimate of the labor/time the feature could save if adopted

Scale:
- `Pilot Essentiality`: High / Medium / Low
- `Value`: High / Medium / Low
- `Implementation Effort`: Low / Medium / High
- `Privacy/Security`: Low / Medium / High

## Recommendation Summary

The most pilot-essential features are still the ones that make the app immediately useful on shift with low friction:
- line worker task flow
- supervisor job checkoff
- reference sheets
- find an item
- two-minute trainings
- pilot mode

Those are the best first pilot features because they are broadly useful, relatively light to support, and easy to put in front of real users right away.

The most operationally valuable heavier features are:
- points assignment
- point approval
- point history
- daily shift reports

Those should not be treated as low-value just because they are more complex. They can save real manager and supervisor time, but they are not as clean or easy as first-wave pilot features.

## Ranked Features

| Rank | Feature | Current App Area | Value | Implementation Effort | Privacy/Security | Pilot Essentiality | Potential Time Savings | Reason |
|---|---|---|---|---|---|---|---|---|
| 1 | Line worker task flow | Dashboard > Workflow > Line > Employee/Line Worker | High | Low | Low | High | ~1,000+ hrs/yr across line shifts (~$14k+/yr at $14/hr), using a conservative 5 min saved per worker per shift | Most essential pilot feature because it is the core shift tool, already broadly useful, and combines high value with low effort and low rollout risk. |
| 2 | Supervisor job checkoff | Dashboard > Workflow > Line > Supervisor > Jobs/Secondaries/Deep Clean | High | Medium | Low | High | ~150-300 supervisor hrs/yr through faster assignment, checkoff, and fewer in-person follow-ups | Core pilot feature with strong shift value. It speeds supervision immediately and makes the pilot more useful to leadership on day one. |
| 3 | Reference sheets | Dashboard > References | High | Low | Low | High | ~100-200 hrs/yr from fewer questions, faster lookups, and less supervisor interruption | High pilot value, very low effort, and broadly useful across many shifts. This is one of the safest high-return pilot features. |
| 4 | Find an item / locker lookup | References > Find an Item | High | Low | Low | High | ~100-180 hrs/yr from faster item lookup for workers plus reduced interruption of supervisors and experienced staff | Very pilot-friendly and highly practical. Even small lookup savings compound quickly across many workers and shifts. |
| 5 | Two-minute trainings | Dashboard hub > Two-minute Trainings | Medium | Low | Low | High | ~60-120 hrs/yr in prep and repeated explanation time, plus better training consistency | Not as operationally critical as workflows, but very pilot-friendly, low effort, and useful every day. |
| 6 | Pilot mode | App profile / config mode | Medium | Low | Low | High | Indirect savings only, but it removes login/setup friction across every pilot test session | Not a big steady-state labor saver, but highly essential to the pilot itself because it reduces friction and makes rollout/testing practical. |
| 7 | Lead trainer task flow | Dashboard > Workflow > Line > Lead Trainer | High | Medium | Low | High | ~100-220 hrs/yr in trainer time through better structure, faster checkoff, and less repeated verbal instruction | Strong pilot feature once stable because it directly helps lead trainers move faster and be more thorough. |
| 8 | Kitchen jobs references/recipes | Dashboard > Workflow > Kitchen Jobs | Medium | Medium | Low | High | ~60-140 hrs/yr plus reduced food waste from fewer mistakes, rework, and burned product | Good pilot feature because it helps new workers and can save both labor and product waste when cooks need quick answers. |
| 9 | Daily shift report drafting | Supervisor flow > Daily Shift Report | High | Medium | Medium | Medium | ~150-250 supervisor hrs/yr from faster end-of-shift reporting and more consistent structure | Very valuable, but slightly less pilot-essential than the core shift flows because it is more process-heavy and touches stored records. |
| 10 | Student manager landing-page announcements | Home + manager portal | Medium | Medium | Low | Medium | ~40-100 hrs/yr from fewer repeated verbal reminders and cleaner communication | Useful in a pilot, but not as essential as workflows and references. |
| 11 | Points assignment | Dashboard / Student Manager Portal | High | High | High | Medium | ~80-180 hrs/yr from eliminating handwritten point slips, binder handling, and delayed manual follow-up | This is genuinely high value, but it ranks lower because it is higher effort, higher sensitivity, and less essential than the core pilot surfaces. |
| 12 | Leadership daily shift report viewing | Dashboard > Daily Shift Reports | High | Medium | Medium | Medium | ~60-140 leadership hrs/yr from centralized report review instead of paper, texts, or verbal handoff | Valuable once reports exist, but secondary to drafting and the core pilot operations. |
| 13 | Point approval workflow | Manager review flow | High | High | High | Medium | ~60-120 hrs/yr by removing manual approval chasing and scattered review steps | High value, but heavier and more sensitive than the simpler pilot features above it. |
| 14 | Stored personal point history | Backend points data | High | High | High | Medium | ~40-100 hrs/yr from eliminating binder lookup and rebuilding old point history by hand | Important long-term value, but not as pilot-essential as the live operational tools. |
| 15 | Point acknowledgment by employee initials | Points confirmation flow | High | High | High | Medium | ~40-100 hrs/yr from reducing signature chasing and long-delayed acknowledgment follow-up | Useful, but it depends on the broader points workflow and carries the same rollout complexity. |
| 16 | Dishroom worker flow | Dashboard > Workflow > Dishroom | High | Medium | Low | Medium | ~120-250 hrs/yr once stable through less retraining and cleaner task execution | Potentially very valuable, but still less essential than the line-centered pilot surfaces. |
| 17 | Night custodial flow | Dashboard > Workflow > Night Custodial | High | Medium | Low | Medium | ~100-220 hrs/yr once stable through reduced retraining and missed cleaning steps | High operational value, but less central to the current pilot than line workflows. |
| 18 | Dishroom lead trainer flow | Dashboard > Workflow > Dishroom Lead Trainer | Medium | Medium | Low | Medium | ~60-120 hrs/yr once stable through faster training and better checkoff | Useful, but it depends on dishroom maturity and is less essential to the immediate pilot. |
| 19 | Home announcements editing | Manager portal | Medium | Medium | Medium | Low | ~20-60 hrs/yr from faster publishing versus manual relaying | Helpful, but not especially pilot-essential and not a top value/effort win. |
| 20 | Aloha + Choices reference | References > Aloha + Choices | Medium | Low | Low | Low | ~20-60 hrs/yr from quicker leftover and setup lookups | Useful niche reference, but narrower than the top pilot features. |
| 21 | Line secondary + checkoff reference | References > Line Secondary + Checkoff | Medium | Low | Low | Low | ~20-50 hrs/yr through faster close/checkoff lookups | Helpful, though more limited in scope than the broader reference and workflow tools. |
| 22 | Condiments rotation reference | References > Condiments Rotation | Low | Low | Low | Low | ~10-40 hrs/yr from occasional rotation lookup savings | Good to have, but narrow and not pilot-essential. |
| 23 | Dining map | References > Dining Map | Low | Low | Low | Low | ~10-30 hrs/yr, mostly for newer workers and occasional wayfinding questions | Helpful onboarding aid, but one of the lower-return pilot features. |
| 24 | Role selection by actual user capability | Dashboard routing / auth-based gating | Low | Medium | Medium | Low | Small indirect savings only; mostly governance and UX polish | Useful later, but not essential to a pilot and not a strong time-savings feature. |
| 25 | Login / JWT auth | Auth flow | Low | Medium | High | Low | Little to no direct labor savings; mostly governance and access control value | Important for production hardening, but not for pilot-essential ranking and not a time-savings priority. |
| 26 | Profile tab | Profile | Low | Low | Medium | Low | Little to no direct labor savings | Lowest pilot-essentiality and lowest operational return among the current features. |

## Main Takeaway

The first-wave pilot should still center on the features that make the app obviously useful with low rollout friction.

At the same time, the ranking should not pretend that points and reporting are low-value. They are high-value features with real labor-saving potential. They just rank lower here because pilot essentiality, effort, and sensitivity still matter.
