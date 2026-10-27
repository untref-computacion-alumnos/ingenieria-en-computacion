# Product vision

## Problem

Students of Ingeniería en Computación juggle several study plans (the degree changed more than once),
SIU Guaraní, the virtual classroom and the faculty website. Generic tools such as unimalla.com cover
many universities and many features, so they feel crowded and not integrated with our faculty.

## Vision

A small, focused companion for **this** degree: it shows the curriculum as a grid, tracks each
student's progress against their own study plan, and gradually connects with the systems a student
already uses, so it removes work instead of adding it.

## Principles

1. **Grid first.** Everything else earns its place after the grid is good.
2. **Not an extra chore.** Prefer importing or deriving data over asking users to type it.
3. **Optional modules.** Non-essential tools (Pomodoro, notes, attendance) live behind feature flags.
4. **Private by default.** Academic progress is visible only to its owner unless they choose otherwise.
5. **Small steps.** Tiny user stories, one at a time, always shippable.
6. **Community with guardrails.** Reviews and forum need moderation from day one of their existence.

## Audiences (in priority order)

1. **Students** — see the plan, mark progress, know what they can take next.
2. **Teachers** — later: subject info, syllabus, announcements, feedback visibility.
3. **Applicants** — later: public read-only view of the degree.
4. **Admins / student center** — maintain plans, subjects, moderation; minimal tooling at first.

## Roadmap (themes, not dates)

| Stage | Theme | Notes |
| --- | --- | --- |
| 0 | Walking skeleton | App, CI, test env deployed |
| 1 | **MVP**: grid + account + progress | See `user-stories/mvp/` |
| 2 | Curriculum management | Admin panel, CSV import, equivalences, change proposals |
| 3 | Student tools | Grades/average, calendar, schedule, tasks, syllabi |
| 4 | Community | Suggestions board, threads, per-subject discussion |
| 5 | Reviews | Verified-anonymous or public, structured ratings, moderation |
| 6 | Integrations | SIU import, classroom, faculty news, iCal, Telegram, push |
| 7 | Optional modules | Pomodoro, notes, attendance |

## Non-goals (for now)

- Multi-university or multi-career support.
- Scraping SIU Guaraní or the classroom with spiders; integration needs faculty permission or a user-provided file.
- Native mobile apps (a responsive web app, possibly installable as PWA, is enough).
