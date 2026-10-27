# Agile process: Scrumban (light Scrum)

## Principles

- **One user story at a time (WIP = 1).** The whole team focuses on a single story. Pair or mob on it;
  beginners learn Rails faster that way.
- Stories are tiny: finish within about 1–2 working days of the team. If it is bigger, split it.
- Always shippable: every merged story leaves `main` green and deployable.

## Roles (rotating is fine for a team of 2–3)

| Role | Responsibility |
| --- | --- |
| Product Owner | Owns the backlog order and acceptance of stories |
| Scrum Master / facilitator | Keeps the process light, runs the retro, unblocks |
| Developers | Everybody; each story is reviewed by someone who did not write most of it |

## Cadence

- **Sprint**: 2 weeks (adjust to the team's real availability; 1 week is fine too).
- **Planning** (30 min): pick the next stories from the top of the backlog. Only commit to what fits.
- **Daily** (async message or 10 min): done / next / blocked.
- **Review** (30 min): demo the `test` environment to the PO; accept or reopen stories.
- **Retrospective** (30 min): one thing to keep, one to change. Write it down in the repo wiki or an issue.
- **Refinement** (during the week, 20 min): split and write the next stories to meet the Definition of Ready.

## Board (GitHub Projects)

`Backlog → Ready → In progress (WIP 1) → In review (WIP 2) → Done`

- A story enters **Ready** only if it meets the [Definition of Ready](definition-of-done.md#definition-of-ready).
- **Done** means it meets the [Definition of Done](definition-of-done.md#definition-of-done) and is merged to `main`.
- Promotion to `test` and `prod` is a release step, tracked with release PRs (see [git workflow](git-workflow.md)).

## Writing stories

- Template: [user-stories/_template.md](../user-stories/_template.md).
- Follow **INVEST**: Independent, Negotiable, Valuable, Estimable, Small, Testable.
- Format: *As a `<role>`, I want `<goal>`, so that `<benefit>`.*
- Acceptance criteria are Gherkin scenarios, copied from the `.feature` file that lives in the repo.
- Size is S (≤ 1 day), M (≤ 2 days). Anything larger is split. No story points needed.

## Metrics worth watching (keep them few)

- Stories finished per sprint (throughput) and age of the oldest story in progress.
- Time from PR opened to merged (should be hours, not days).
