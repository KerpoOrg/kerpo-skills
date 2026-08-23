# Create scaffold

Used by `kerpo-mise-task-create` after reading
[task-conventions.md](task-conventions.md).

## Decide placement

1. If the user wants a multi-step / multi-cmd domain → **file task** under
   `.mise/tasks/<name>` with nested `#USAGE cmd` blocks.
2. If truly a one-liner (see conventions) → TOML `[tasks.<name>]` with
   `description`, `usage`, and single-line `run`.
3. Refuse names/aliases in [reserved-mise-commands.md](reserved-mise-commands.md).

## File task checklist

1. Create `.mise/tasks/<name>` (or group path if namespaced **separate** tasks —
   not for subcommands).
2. Shebang `#!/usr/bin/env bash`, `set -euo pipefail`.
3. `#MISE description="…"`.
4. `#USAGE` with `cmd` blocks + `help=` per subcommand; `subcommand_required=#true`
   when appropriate; confirmation flags for destructive cmds.
5. `chmod +x` the task file.
6. Keep helpers colocated; do not invent `scripts/<task>.sh` for task-private logic.
7. Ensure `[tools]` includes `shellcheck` and `bats` (add if missing).
8. Write `tests/mise-tasks/<name>.bats` stub covering:
   - `mise run <name> -- --help` (or equivalent)
   - each subcommand `--help`
   - at least one happy-path stub (skip/mock if needs network/secrets)
9. Run `shellcheck` on the new script(s); fix before finishing.
10. If the project lacks a lint/test entrypoint for mise tasks, add or extend a
    non-colliding domain task (e.g. `ci` with `lint` / `test` subcommands).

## Minimal bats stub

```bash
#!/usr/bin/env bats
# tests/mise-tasks/example.bats

setup() {
  PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  cd "$PROJECT_ROOT"
}

@test "example --help prints usage" {
  run mise run example -- --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* ]] || [[ "$output" == *"usage"* ]] || [[ "$output" == *"cmd"* ]]
}
```

## Report

Tell the user: path created, how to invoke (`mise run … -- …`), bats path,
shellcheck status, and any reserved-name refusal.
