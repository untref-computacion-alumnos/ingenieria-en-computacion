<!-- markdownlint-disable MD041 -->
<!--
Title format: "type(us-NN): short summary", like a commit (e.g. "feat(us-011): render grid by term").
Target branch: main (test and prod only receive promotions from main).
-->

## Story

Story: US-___ (link to the issue)

## What and why

<!-- What changes and why. One or two sentences; the story has the details. -->

## How to test

<!-- Steps for the reviewer, or the .feature scenarios that cover it. -->

1.
2.

## Screenshots

<!-- UI changes only: before / after. Delete this section otherwise. -->

## Definition of done

- [ ] .feature scenarios pass
- [ ] RSpec added (red → green → refactor)
- [ ] Linters clean (`bin/dc bin/ci`)
- [ ] Coverage ≥ 90 %, Brakeman and bundler-audit clean
- [ ] No hard-coded UI text (I18n)
- [ ] Docs updated

## Notes for the reviewer

<!-- Risky areas, trade-offs, follow-ups, migrations, new env vars. -->
