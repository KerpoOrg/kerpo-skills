---
name: kerpo-git-worktree-add
description: >-
  Use when the user wants to create a git linked worktree for isolated or
  multiagent work. Apply when the user says "create a worktree", "add a
  worktree", "isolate this on a worktree", or "new worktree for this branch".
  Creates the branch if it does not exist. Does not activate for branch-only
  create (kerpo-git-branch-create), entering/moving the agent into a worktree
  (kerpo-git-worktree-enter), human-triggered cleanup (kerpo-git-worktree-clean),
  or resolving which worktree you are in (kerpo-git-context).
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-git-worktree-add

Adds a linked git worktree. If the target branch does not exist, creates it
with the worktree (`git worktree add -b`).

## Instructions

### Step 1 — Resolve repo and conventions

1. Resolve the **primary** repo root with `kerpo-git-context` (common dir /
   main worktree — not an arbitrary linked tree unless the user said so).
2. Read [references/conventions.md](references/conventions.md): layout, naming,
   base ref, pinned primary, reserved names.

### Step 2 — Decide path, branch, base

- **Branch** — user name, or derive from issue/slug + project prefix
- **Path** — from conventions; else `<primary>/worktree/<slug>` where slug is
  the branch with `/` → `-`
- **Base** — user or discovered default (`origin/main` preferred when remote exists)

Ensure the parent directory exists. If using the fallback `worktree/` and it is
not gitignored, propose `/worktree/` in `.gitignore` and wait for confirm before
writing.

### Step 3 — Branch existence

```bash
git -C <primary> worktree list --porcelain
git -C <primary> show-ref --verify --quiet refs/heads/<branch>
# optional: refs/remotes/origin/<branch>
```

- Branch **missing** → create with worktree:
  `git -C <primary> worktree add -b <branch> <path> <base>`
- Branch **exists** and is **not** checked out in another worktree →
  `git -C <primary> worktree add <path> <branch>`
- Branch **already checked out** elsewhere → stop; report the other path; ask
  whether to reuse that worktree (`kerpo-git-worktree-enter`) instead of adding

Refuse to overwrite a non-empty path that is not already this worktree.

### Step 4 — Report

- Worktree path (absolute)
- Branch and base
- Created branch? yes/no
- Suggest `kerpo-git-worktree-enter` if the user intends to work there next

Do **not** call worktree cleanup from this skill. Do **not**
`move_agent_to_root` unless the user also asked to start working there — then
compose with `kerpo-git-worktree-enter` after add succeeds.

## Gotchas

- Primary checkout should remain on the default branch when conventions say so
- Never `git worktree remove` here
- `git -C` against the primary for `worktree add`; verify with
  `git -C <new-path> branch --show-current`
