# Contributing

[Español](CONTRIBUTING_ES.md) · English

Thanks for helping out. This guide describes how work flows from a user story
to `main`. Setup instructions live in the [README](README.md).

## Workflow at a glance

1. Pick a story from the board (`Ready` column) and move it to `In progress`.
   Keep a single story in progress at a time.
2. Branch from an up-to-date `main`.
3. Write the `.feature` scenarios, then the specs, then the code.
4. Run `bin/dc bin/ci` until it is green.
5. Open a pull request and fill in the template.
6. Address review comments, get one approval, merge.

## Branches

| Branch | Purpose |
| --- | --- |
| `main` | Integration; every PR targets it |
| `test` | Staging; promoted from `main` |
| `prod` | Production; promoted from `test` |

`main`, `test` and `prod` are protected: no direct pushes, no force pushes, no
deletions. Name your working branches after the story, for example
`us-012-student-signup`, in lowercase.

## Development process

We follow BDD with TDD inside it:

1. **Acceptance**: write or update the Gherkin scenarios in `features/`.
   They must be readable by non-developers and pass `cuke_linter`.
2. **Red**: write a failing RSpec example for the next small behaviour.
3. **Green**: write the simplest code that passes it.
4. **Refactor**: clean up with the tests green.
5. Repeat until the scenarios pass.

Conventions:

- No hard-coded UI text: use I18n (`config/locales/`). `i18n-tasks health`
  must pass, and the default locale is `es-AR`.
- Authorization goes through Pundit policies; cover them with
  `pundit-matchers`.
- Prefer small ViewComponents over large partials.
- Keep migrations reversible and never edit one that is already merged.
- Secrets never go in git; use Rails credentials and GitHub secrets.

## Commits

Every commit message follows `type(us-NN): description`:

```text
feat(us-012): add student signup form
fix(us-015): handle empty course list
docs(us-020): explain how to run Cucumber
```

Accepted types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `ci`,
`build`, `perf`, `style` and `revert`. `us-NN` is the story number, in
lowercase. Messages that git generates for merges (`Merge ...`) and reverts
(`Revert "..."`) are also accepted. commitlint rejects anything else, locally through Lefthook and in CI on pull
requests (rules in `.commitlintrc.yml`; install it once with
`npm install -g @commitlint/cli`). Keep
commits focused and write the description in the imperative mood.

If your branch starts with a story id (`us-012-student-signup`), Lefthook
pre-fills the message with `(us-012):`. Type the commit type before the
parenthesis and the description after it. It does nothing with `-m`, merges or
amends.

### Author identity

Commits must show your real first and last name, not a username. Set it once:

```bash
git config user.name "First Last"
git config user.email "you@example.com"
```

Lefthook rejects a commit when `user.name` is a single word. If someone already
committed under another name or email, add a line to `.mailmap` so history
tools show one person:

```text
First Last <you@example.com> old-username <old.email@example.com>
```

Check it with `git shortlog -sne`. GitHub ignores `.mailmap`: it groups authors
by email, so add every email you commit with to your GitHub account.

## Quality checks

```bash
bin/dc bin/ci
```

`bin/ci` runs `bin/lint`, `bin/security`, `bin/advisory` and `bin/test`; each
one can be run on its own.

This is the same set of commands CI runs: RuboCop, ERB Lint, markdownlint,
yamllint, cuke_linter, i18n-tasks, Brakeman, bundler-audit, RSpec, Cucumber
and the coverage gate. Reek and Rails Best Practices are advisory. Install
the Git hooks once with `bundle exec lefthook install`.

## Pull requests

- Title: `type(us-NN): short summary`, like a commit.
- Link the story and complete every item of the template's checklist.
- Keep PRs small and focused; split unrelated changes.
- CI jobs `lint`, `security` and `test` must pass.
- One approval is required, stale approvals are dismissed on new commits, and
  all conversations must be resolved.
- Merge with a **merge commit** (squash and rebase are disabled). The branch
  is deleted after merging.

### Reviewing

- Check the behaviour against the story's acceptance criteria.
- Look for missing tests, hard-coded text, N+1 queries and authorization gaps.
- Be specific and kind; suggest changes rather than only pointing out issues.

## Definition of done

A story is done when:

- [ ] The `.feature` scenarios pass
- [ ] RSpec examples were added (red → green → refactor)
- [ ] Linters are clean (`bin/dc bin/ci`)
- [ ] Coverage is at least 90 %, and Brakeman and bundler-audit are clean
- [ ] There is no hard-coded UI text (I18n)
- [ ] Docs are updated

See [definition-of-done.md](docs/process/definition-of-done.md) for details.

## Reporting problems

Open a GitHub issue with what you expected, what happened and the steps to
reproduce it. For security problems, do not open a public issue; contact the
maintainers directly.
