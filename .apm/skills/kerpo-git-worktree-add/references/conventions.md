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
