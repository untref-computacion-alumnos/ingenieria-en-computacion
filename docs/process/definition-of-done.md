# Definition of Ready and Definition of Done

## Definition of Ready

A story can enter the **Ready** column only if:

- [ ] It follows the template and has a clear role, goal and benefit.
- [ ] It is small (S or M) and independent enough to be built alone.
- [ ] Acceptance criteria exist as Gherkin scenarios and the team understood them.
- [ ] Out-of-scope items are listed.
- [ ] Data/model impact and UI notes are written (rough is fine).
- [ ] Dependencies on earlier stories are done.

## Definition of Done

A story is **Done** only if all items are true:

**Behavior**

- [ ] The `.feature` file for the story exists in `features/` and every scenario passes.
- [ ] Unit/request/component/policy specs (RSpec) cover the new code (TDD).
- [ ] The story markdown and the `.feature` file say the same thing.

**Quality gates (enforced by CI)**

- [ ] RuboCop, erb_lint, markdownlint, yamllint, cuke_linter and i18n-tasks pass.
- [ ] Brakeman and bundler-audit report nothing new.
- [ ] Bullet reports no N+1 queries in the tests that exercise the feature.
- [ ] Total coverage is at least **90 %** (SimpleCov).

**Review and delivery**

- [ ] PR approved by at least one other team member; all comments resolved.
- [ ] Merged into `main` with a merge commit; the story branch is deleted.
- [ ] All user-visible text is in I18n files (es-AR), none hard-coded.
- [ ] Docs touched by the change are updated (story file, `CLAUDE.md` if a decision changed).
- [ ] Verified on the `test` environment after the next release PR (PO acceptance).

## Pull request checklist (copy into `.github/pull_request_template.md`)

```markdown
Story: US-___ (link)

- [ ] .feature scenarios pass
- [ ] RSpec added (red → green → refactor)
- [ ] Linters clean (`bin/ci`)
- [ ] Coverage ≥ 90 %, Brakeman and bundler-audit clean
- [ ] No hard-coded UI text (I18n)
- [ ] Docs updated
```
