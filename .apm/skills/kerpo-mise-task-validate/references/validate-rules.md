# Validate rules

Used by `kerpo-mise-task-validate`. Read
[task-conventions.md](task-conventions.md) and
[reserved-mise-commands.md](reserved-mise-commands.md) first.

## Severity

| Level | Meaning |
|-------|---------|
| **error** | Must fix before treating tasks as compliant; refactor skill targets these |
| **warn** | Should fix; may leave with explicit user ack |

## Inventory

1. Root `mise.toml` / `.mise.toml` `[tasks.*]`
2. File tasks under `.mise/tasks/` (executable; skip non-executable `_*.sh` libs
   from “missing bats” only if documented as helpers — still shellcheck them)
3. `tests/mise-tasks/*.bats`
4. `[tools]` for `shellcheck` / `bats`

## Errors

- Task name or alias ∈ reserved mise CLI list
- Related hyphenated siblings that should be one task + subcommands
  (`foo-bar` + `foo-baz` → `foo` with cmds)
- Multi-line / control-flow / secrets logic still in root TOML `run`
- Missing `#USAGE` / `usage` so `--help` cannot work; `cmd` without `help=`
- File task missing shebang or execute bit
- No bats file for a file task (`tests/mise-tasks/<task>.bats`); map `group:name`
  → `tests/mise-tasks/group-name.bats` or `group_name.bats` — pick one scheme
  and state it in the report (prefer `<task-with-colons-replaced-by-dashes>.bats`)
- `shellcheck` failure on task/helper scripts
- Secrets/tokens in committed mise.toml or task scripts
- Silent `git commit` / `git push` / destructive ops without named help and
  (for destructive) `--yes`-style confirmation

## Warns

- Missing `#MISE description` / TOML `description` when usage exists
- Hand-rolled `echo` help instead of (or conflicting with) usage spec
- Task-only / mise-context script under `scripts/` (or similar)
- Duplicate `run` bodies under different names
- `shellcheck` / `bats` not pinned in `[tools]`
- No project entrypoint to run shellcheck + bats for mise tasks
- shfmt drift when the repo already uses shfmt

## Report format

```text
mise task validate — <repo-root>
errors: N
warns: M

[error] <task-or-path>: <rule> — <detail>
[warn]  <task-or-path>: <rule> — <detail>

Next: kerpo-mise-task-refactor (if errors) or fix manually.
```

Do **not** rewrite files in validate unless the user explicitly asked to fix.
