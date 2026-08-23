# Refactor playbook

Used by `kerpo-mise-task-refactor` after
[task-conventions.md](task-conventions.md) and (preferably) a validate pass.

## Order of operations

1. Inventory tasks (TOML + `.mise/tasks/`) and latest validate findings.
2. **Rename** CLI-shadowed names → domain task + subcommands (update docs/README
   mentions of `mise run <old>`).
3. **Collapse** hyphen sprawl / sibling tasks into one file task with `#USAGE cmd`.
4. **Move** non-one-liner TOML `run` bodies into `.mise/tasks/<name>`; delete
   obsolete TOML task blocks (keep `[tools]` / `[env]`).
5. **Relocate** task-private scripts from `scripts/` into `.mise/tasks/` (or
   inline) when they are not safe/useful standalone.
6. Add `#MISE` / `#USAGE` help for every task and subcommand; confirmation flags
   for destructive cmds; strip committed secrets → `mise.local.toml` / `op` / env.
7. Pin `shellcheck` + `bats` in `[tools]` if missing.
8. Add/update `tests/mise-tasks/<task>.bats`; ensure shellcheck clean.
9. Add or extend a non-colliding `ci` (or similar) task with `lint` / `test`
   subcommands that run shellcheck over `.mise/tasks` and bats under
   `tests/mise-tasks/`.
10. Re-run validate mentally / via `kerpo-mise-task-validate`; report remaining
    warns.

## Confirm before

- Deleting tasks or scripts
- Changing public task names that other docs/CI call
- Anything that rewrites production deploy/push behavior

## Minimal migration example

Before (`mise.toml`):

```toml
[tasks.install]
run = "…"
[tasks.uninstall]
run = "…"
```

After: `.mise/tasks/skills` with `cmd "install"` / `cmd "uninstall"`, bats at
`tests/mise-tasks/skills.bats`, and callers use `mise run skills -- install`.
