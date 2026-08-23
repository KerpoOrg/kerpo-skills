---
name: kerpo-mise-task-refactor
description: >-
  Use when refactoring or migrating mise tasks to kerpo conventions: move
  complex TOML runs into .mise/tasks, rename CLI-shadowed names into domain
  tasks with usage subcommands, relocate task-private scripts, add usage
  help, shellcheck/bats wiring, and confirmation flags for destructive
  commands. Apply when the user says "refactor mise tasks", "migrate tasks
  to .mise/tasks", "fix shadowed mise install task", or "collapse
  hyphenated mise tasks into subcommands". Does not activate for create-only
  scaffolding (kerpo-mise-task-create) or report-only audit
  (kerpo-mise-task-validate) unless the user also asked to fix.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-mise-task-refactor

Applies kerpo mise-task conventions to an existing project: migrate, rename,
collapse, add help/lint/test, and remove footguns.

## When to use

- “refactor our mise tasks to standards”
- “move complex tasks into `.mise/tasks`”
- “fix the shadowed `install` task / add bats and shellcheck”

## Instructions

1. Prefer a fresh `kerpo-mise-task-validate` pass (or equivalent inventory).
2. Read [references/task-conventions.md](references/task-conventions.md),
   [references/reserved-mise-commands.md](references/reserved-mise-commands.md),
   and [references/refactor-playbook.md](references/refactor-playbook.md).
3. Confirm with the user before deleting tasks, renaming public entrypoints
   that CI/docs call, or changing deploy/push behavior.
4. Execute the playbook order: rename → collapse → move → relocate scripts →
   usage/help → secrets → pin tools → bats/shellcheck → ci lint/test task.
5. Re-check with validate rules; report what changed and remaining warns.

## Gotchas

- Keep one-liners in `mise.toml` only when they meet the one-liner threshold.
- Do not leave task-private dangerous scripts in `scripts/` after migration.
- Updating README / consumer docs that mention old `mise run <name>` is part
  of the rename — do not leave broken invocations.
- Create-only requests belong to `kerpo-mise-task-create`.
