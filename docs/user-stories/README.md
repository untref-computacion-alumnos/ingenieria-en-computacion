# User stories

Stories are small, ordered, and built **one at a time**. Template: [_template.md](_template.md).
Detailed stories exist for the MVP; the rest of the product lives as short stories in `backlog/` and is
expanded (using the template) only when it gets close to the top.

## MVP: grid + account + progress

Work top to bottom. Each story depends only on the ones above it.

| Order | ID | Title | Epic | Size |
| --- | --- | --- | --- | --- |
| 1 | [US-01](mvp/US-01-walking-skeleton.md) | Walking skeleton deployed to test | Foundation | M |
| 2 | [US-02](mvp/US-02-seed-study-plan.md) | Seed the current study plan | Curriculum | M |
| 3 | [US-03](mvp/US-03-list-study-plans.md) | List study plans | Curriculum | S |
| 4 | [US-04](mvp/US-04-view-plan-grid.md) | View a plan as a grid by year and term | Curriculum | M |
| 5 | [US-05](mvp/US-05-subject-detail.md) | See a subject's detail | Curriculum | S |
| 6 | [US-06](mvp/US-06-highlight-prerequisites.md) | Highlight prerequisites on interaction | Curriculum | M |
| 7 | [US-07](mvp/US-07-sign-up.md) | Sign up with email and password | Accounts | S |
| 8 | [US-08](mvp/US-08-log-in-out.md) | Log in and log out | Accounts | S |
| 9 | [US-09](mvp/US-09-reset-password.md) | Reset my password | Accounts | S |
| 10 | [US-10](mvp/US-10-select-my-plan.md) | Select my study plan | Accounts | S |
| 11 | [US-11](mvp/US-11-mark-subject-status.md) | Mark a subject's status | Progress | M |
| 12 | [US-12](mvp/US-12-subject-availability.md) | See which subjects I can take | Progress | M |
| 13 | [US-13](mvp/US-13-progress-percentage.md) | See my progress percentage | Progress | S |
| 14 | [US-14](mvp/US-14-grade-and-date.md) | Record grade and approval date | Progress | S |
| 15 | [US-15](mvp/US-15-privacy-notice.md) | Privacy notice and terms | Privacy | S |

Release milestone: when US-15 is done the MVP is ready to promote to `prod`.

## Backlog (beyond the MVP)

ID ranges are reserved per epic.

| Epic | File | IDs |
| --- | --- | --- |
| Curriculum management | [backlog/curriculum-management.md](backlog/curriculum-management.md) | US-1xx |
| Accounts and privacy | [backlog/accounts-and-privacy.md](backlog/accounts-and-privacy.md) | US-2xx |
| Student tools | [backlog/student-tools.md](backlog/student-tools.md) | US-3xx |
| Community | [backlog/community.md](backlog/community.md) | US-4xx |
| Reviews | [backlog/reviews.md](backlog/reviews.md) | US-5xx |
| Integrations | [backlog/integrations.md](backlog/integrations.md) | US-6xx |
| Teachers and applicants | [backlog/teachers-and-applicants.md](backlog/teachers-and-applicants.md) | US-7xx |
| Optional modules | [backlog/optional-modules.md](backlog/optional-modules.md) | US-8xx |

Suggested order after the MVP: curriculum management → accounts/privacy → student tools → integrations
(SIU manual import) → community → reviews → teachers/applicants → optional modules.
