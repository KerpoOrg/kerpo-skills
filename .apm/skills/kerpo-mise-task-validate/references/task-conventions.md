# Kerpo mise task conventions

Global standards for project mise tasks. Shared by `kerpo-mise-task-create`,
`kerpo-mise-task-validate`, and `kerpo-mise-task-refactor`.

## Layout

| Kind | Where |
|------|--------|
| File tasks (default) | Executable scripts under `.mise/tasks/` (mise default discovery) |
| TOML one-liners only | Root `mise.toml` `[tasks.*]` — see [One-liner threshold](#one-liner-threshold) |
| Task-private helpers | Colocated under `.mise/tasks/` (e.g. `.mise/tasks/skills/_lib.sh`) — **not** executable as standalone tasks if they are libraries (no execute bit, or name with leading `_` and document as non-task) |
| Bats tests | `tests/mise-tasks/<task>.bats` (outside task discovery) |
| Lint/test tools | Pin `shellcheck` and `bats` (bats-core) in `[tools]` |

File tasks use `#MISE` header metadata (`description`, `depends`, `alias`, `dir`, …)
and `#USAGE` / usage specs — not a giant multi-line `[tasks.*]` block in TOML.

Subdirectories under `.mise/tasks/` become namespaced tasks (`group:name`) for
**separate** tasks. That is **not** a substitute for subcommands on one domain task.

## One-liner threshold

A task may stay in root `mise.toml` only if **all** of:

- `run` is a **single** shell command or **single** pipeline (`a | b`)
- No `if` / `for` / `while` / `case`, no heredocs, no multi-line `run = """…"""`
- No secrets handling or non-trivial logic
- Has `description` and a minimal `usage` (or equivalent) so `mise run <task> -- --help` works

`depends = […]` plus a one-line `run` is allowed in TOML.

Everything else → `.mise/tasks/<name>` file task.

## No CLI name collisions

Task names and `#MISE alias` / TOML `alias` values must **not** match mise
top-level commands or their short aliases. Built-ins win over `mise <TASK>`
shorthand, so a task named `install` is shadowed by `mise install`.

See [reserved-mise-commands.md](reserved-mise-commands.md). Prefer a domain
task + subcommand (e.g. `skills` → `install`) over renaming to `skills-install`.

Validate as **error**; create refuses; refactor renames.

## Subcommands over hyphen sprawl

Prefer one task with nested usage `cmd` subcommands:

```text
mise run task1 -- cmd1|cmd2 …args
```

Avoid `task1-cmd1`, `task1-cmd2`, or `skills-auth` / `skills-install` /
`skills-update` as three top-level tasks.

Use `#USAGE cmd "…" help="…"` blocks ([usage cmd](https://usage.jdx.dev/spec/reference/cmd)).
Set `subcommand_required=#true` when a bare `mise run <task>` must not run a default action.

## Help and usage (required)

- Every task: `mise run <task> -- --help` (and `-h`) prints usable usage
- Every subcommand: `help=` on the `cmd`; `mise run <task> -- <cmd> --help` works
- Missing/invalid invocation surfaces usage via the usage spec (not a bare opaque error)
- Prefer `#USAGE` / `usage = '''…'''` over hand-rolled `echo` help
- TOML one-liners still need `description` + minimal `usage`

## Script placement

- Tasks **may** call tools/scripts outside `.mise/tasks/` (repo `scripts/`,
  `[tools]` CLIs, docker, npm, …)
- **Do not** put task-only or mise-context-dependent scripts in `scripts/` when:
  - They are useless as a standalone developer entrypoint, or
  - Running them bare is misleading/dangerous without mise env/tools/secrets/cwd
- Keep those as the file task body or colocated helpers under `.mise/tasks/`
- **OK outside:** reusable developer tooling with safe standalone semantics and
  documented prerequisites

## Lint and test

- All file tasks and colocated shell helpers must pass **shellcheck**
- When the repo adopts **shfmt**, also require `shfmt -d` clean
- Every file task needs **bats** coverage under `tests/mise-tasks/<task>.bats`:
  - Task `--help` / usage
  - Each subcommand `--help`
  - Happy path (mocked/stubbed where destructive)
  - Edge cases for destructive or context-sensitive cmds
- Pin in `[tools]`:

  ```toml
  shellcheck = "latest"   # or pin a version
  bats = "latest"         # bats-core
  ```

- Expose project lint/test entrypoints as proper mise tasks that do **not**
  collide with CLI names — prefer a domain task with subcommands, e.g.
  `mise run ci -- lint` / `mise run ci -- test` (not a task named `install`)

## Secrets

- **Error:** tokens/passwords/API keys in committed `mise.toml` or task scripts
- Use `mise.local.toml` (gitignored), `op read`, or env vars documented in usage

## Side effects and destructive actions

Locked defaults:

- `git commit` / `git push` / similar mutating VCS in a task → **error** unless
  the task/subcommand name **and** usage `help=` explicitly describe that
  behavior (no silent deploy/push)
- Destructive actions (db reset, uninstall, rm -rf of project dirs, etc.) →
  require a confirmation flag in the usage spec (e.g. `--yes` / `-y`) **and**
  clear help text; bats should cover refusal without `--yes`
- Surprising side effects without naming → validate **error** (or **warn** only
  when help already names them clearly)

## Canonical file-task shape

```bash
#!/usr/bin/env bash
#MISE description="Manage project skills (apm pack/install/auth)"
#USAGE subcommand_required=#true
#USAGE cmd "auth" help="Write APM token into mise.local.toml from gh" {
#USAGE   flag "-u --user <user>" help="gh keyring user"
#USAGE }
#USAGE cmd "install" help="Pack and install skills locally (claude + cursor)"
#USAGE cmd "uninstall" help="Remove deployed skills from agent skill dirs" {
#USAGE   flag "-y --yes" help="Confirm destructive uninstall"
#USAGE }
set -euo pipefail
# Dispatch using usage-parsed command / flags (usage_* env vars).
…
```

Invoke: `mise run skills -- --help`, `mise run skills -- auth --help`,
`mise run skills -- auth`.
