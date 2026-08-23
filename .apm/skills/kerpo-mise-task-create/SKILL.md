---
name: kerpo-mise-task-create
description: >-
  Use when creating a new mise task (file task under .mise/tasks or a TOML
  one-liner) that follows kerpo conventions: non-colliding names, usage
  subcommands with help, shellcheck-clean scripts, and bats stubs under
  tests/mise-tasks. Apply when the user says "add a mise task", "create a
  mise file task", "scaffold .mise/tasks", or "new mise run command with
  subcommands". Does not activate for validating existing tasks
  (kerpo-mise-task-validate), rewriting/migrating task layout
  (kerpo-mise-task-refactor), or generic shell-script authoring unrelated to
  mise.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-mise-task-create

Scaffolds a new mise task to kerpo standards: prefer `.mise/tasks/` file
tasks with nested `#USAGE cmd` help, refuse CLI-shadowing names, and ship
shellcheck-clean scripts plus bats stubs.

## When to use

- “add a mise task for …”
- “create `.mise/tasks/foo` with auth|install subcommands”
- “scaffold a mise file task with usage help and bats”

## Instructions

1. Read [references/task-conventions.md](references/task-conventions.md) and
   [references/reserved-mise-commands.md](references/reserved-mise-commands.md).
2. Follow [references/scaffold.md](references/scaffold.md): placement → name
   check → file or TOML one-liner → `#MISE`/`#USAGE` → `chmod +x` → pin
   shellcheck/bats → `tests/mise-tasks/<name>.bats` → run shellcheck.
3. Do not place task-private logic in `scripts/` when it is only safe via
   `mise run`.
4. Report paths and example invocations (`mise run <task> -- <cmd> --help`).

## Gotchas

- Never name a task `install`, `uninstall`, `run`, `exec`, etc. — use a
  domain task + subcommand.
- Hyphenated sibling tasks (`foo-bar`, `foo-baz`) are the wrong shape; create
  one `foo` with cmds instead.
- Bats files must not be executable under `.mise/tasks/` or mise may treat
  them as tasks — keep them in `tests/mise-tasks/`.
- Does not rewrite the whole project’s tasks — that is
  `kerpo-mise-task-refactor`.
