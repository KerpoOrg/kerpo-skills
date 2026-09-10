---
name: kerpo-mise-task-validate
description: >-
  Use when auditing or validating project mise tasks against kerpo
  conventions: .mise/tasks layout, CLI name shadowing, subcommand sprawl,
  usage/help, script placement, secrets, shellcheck, and bats coverage.
  Apply when the user says "validate mise tasks", "audit mise.toml tasks",
  "check our mise task quality", or "are our mise tasks compliant". Does not
  activate for creating a new task (kerpo-mise-task-create), applying fixes
  (kerpo-mise-task-refactor), or generic shellcheck of unrelated scripts.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-mise-task-validate

Audits `mise.toml` and `.mise/tasks/**` against kerpo conventions. Reports
errors and warns; does **not** rewrite files unless the user explicitly asks
to fix (then compose `kerpo-mise-task-refactor`).

## When to use

- “validate mise tasks”
- “audit our mise.toml / `.mise/tasks` quality”
- “check for shadowed mise task names / missing bats”

## Instructions

1. Resolve the project root (compose `kerpo-git-context` if checkout is
   ambiguous).
2. Read [references/task-conventions.md](references/task-conventions.md),
   [references/reserved-mise-commands.md](references/reserved-mise-commands.md),
   and [references/validate-rules.md](references/validate-rules.md).
3. Inventory TOML tasks, file tasks, bats files, and `[tools]`.
4. For each file task/helper, run shellcheck when available; note missing
   bats and usage/help gaps; flag reserved names and hyphen sprawl.
5. Report in the validate-rules format (errors first, then warns). Suggest
   `kerpo-mise-task-refactor` when errors exist.

## Gotchas

- Semver or “it works on my machine” is not compliance — missing `--help` or
  bats is still an error.
- Directory groups (`test:units`) are separate tasks, not subcommands — do
  not flag them as hyphen sprawl; do flag `foo-bar` + `foo-baz` siblings.
- Do not silently edit tasks during validate.
