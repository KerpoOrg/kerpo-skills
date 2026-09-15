# Worktree / branch project conventions

Shared discovery for `kerpo-git-branch-create`, `kerpo-git-worktree-add`,
`kerpo-git-worktree-enter`, `kerpo-git-worktree-clean`, and the worktree
compose step in `kerpo-gh-issue-start-work`.

## Discovery order

Stop at the first **clear** hit. Prefer project docs over inference.

1. **Explicit docs** — search the primary checkout (and common process dirs):
   - `**/worktree-conventions.md`, `**/worktrees.md`
   - `.cursor/steering/`, `.cursor/rules/`, `docs/`, `README*`
   - Keywords: `git worktree add`, `worktree/`, “linked worktree”, cleanup order
2. **Rules** — Cursor/Claude rules that mention worktree path, “stay on main”,
   or teardown before remove
3. **Existing layout** — `git worktree list`; folders named `worktree/` or
   `worktrees/` under the primary root; matching `.gitignore` entries
4. **Fallback (kerpo default)** — nested gitignored `./worktree/<slug>`

### Fallback details

When no project convention is found:

```bash
git worktree add -b <branch> worktree/<slug> <base>
```

- Parent dir: `<primary-root>/worktree/`
- Slug: branch name with `/` → `-` (e.g. `feat/login` → `feat-login`)
- If `worktree/` is not gitignored, propose adding `/worktree/` to `.gitignore`
  and **wait for confirmation** before writing the ignore rule
- Do not invent sibling paths (`../repo-feature`) unless the project documents them

## What to extract

When reading project sources, record:

| Field | Examples |
|---|---|
| **Layout** | `./worktree/<name>`, sibling dirs, absolute parent |
| **Branch naming** | `feat/`, `fix/`, issue-number slug |
| **Base ref** | `main`, `master`, `origin/main` |
| **Pinned primary** | Primary checkout must stay on default branch; feature work only in worktrees |
| **Start-work policy** | Require worktree for product work; or root checkout OK |
| **Pre-destroy teardown** | Ordered commands before `git worktree remove` (e.g. stop dev server, `mise run stack rm`) |
| **Reserved worktrees** | Names that must never be removed without explicit user ask |
| **Bootstrap after enter** | Optional one-time setup in a new checkout (`mise trust`, env link, etc.) |

## Start-work policy resolution

Used by `kerpo-gh-issue-start-work` after claiming the issue:

- **Require worktree** — docs/rules say product/feature work goes in a worktree,
  or “never checkout -b on main root”
- **Root OK** — docs allow or prefer working on a branch in the primary checkout
- **Unclear** — ask the developer: worktree, branch on current checkout, or claim-only?

## Session-managed worktrees (check before any policy)

Some agents set up a worktree for the session **before** the prompt runs (T3
Code auto-creates `~/.t3/worktrees/<repo-slug>/<id>` on a `t3code/<slug>`
branch; other harnesses may do the same). The session cannot leave that
worktree without being restarted, so adding another worktree or "entering" one
orphans the agent. The add/enter policy is skipped whenever this applies.

### Detection

Check in this order:

1. **Opt-out** — `KERPO_WORKTREE_MANAGEMENT=off` in the environment: force the
   skip behavior below regardless of detection, and report that the flag was
   honored.
2. **In a linked worktree** — `git rev-parse --show-toplevel` and
   `git rev-parse --path-format=absolute --git-common-dir` disagree on the repo
   root, i.e. the session is already rooted inside a linked worktree. This is
   the structural rule and covers any harness that auto-roots sessions.
3. **Harness marker** (used for the report message only): T3 Code sets
   `__CFBundleIdentifier=com.t3tools.t3code` on macOS, and its worktrees live
   under `~/.t3/worktrees/` on every platform. Either signal identifies T3.

### Skip behavior

When detection (1) or (2) hits, use the **session-managed worktree** as the
working tree — do **not** compose add/enter, even if the start-work policy says
"require worktree":

- Keep the branch the harness chose as-is (do not rename it behind the harness)
- Branch/worktree path comes from the current session, not from conventions
- Report explicitly, never silently: e.g. "Session worktree managed by T3 Code
  — skipping worktree create/enter, using `<path>` on `<branch>`"

If the start-work policy was "root checkout OK" this changes nothing; the only
case skipped is the create/enter compose step.

### Who checks

- `kerpo-gh-issue-start-work` — before applying its Step 5 policy table
- `kerpo-git-worktree-add` — before creating anything (refuse + report)
- `kerpo-git-worktree-enter` — before composing add or telling the user to
  reopen the workspace (entering a different worktree under these harnesses
  requires a new session; warn and stop)

## Pre-destroy teardown

Used only by **`kerpo-git-worktree-clean`** when a **human** asked to clean up.

- If the project lists an order (e.g. stack/rm → then `git worktree remove`), follow it
- If no teardown is documented, skip invented Docker/mise steps — only git remove
  (after dirty-gate)
- Other skills must **not** run teardown or worktree remove; they may remind the
  human that cleanup is available

## Naming helpers

- Branch from issue: `feat/<short-slug>` or project prefix + issue number if that
  is the local convention
- Worktree directory name: prefer project rule; else slugify the branch
- Always `git -C <path>` for operations on a specific checkout
