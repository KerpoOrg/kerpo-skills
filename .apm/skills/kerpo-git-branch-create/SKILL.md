---
name: kerpo-git-branch-create
description: >-
  Use when the user wants to create a git branch without creating a worktree.
  Apply when the user says "create a branch", "branch off main for X", "make a
  feat/fix branch", or "git switch -c". Does not activate for creating or
  entering worktrees (kerpo-git-worktree-add / kerpo-git-worktree-enter),
  cleaning worktrees (human-only kerpo-git-worktree-clean), dirty-file listing
  (kerpo-git-status), or claiming a GitHub issue (kerpo-gh-issue-start-work).
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-git-branch-create

Creates a new git branch on an existing checkout. Does **not** add a worktree.

## Instructions

### Step 1 — Resolve context and conventions

1. Resolve the target checkout with `kerpo-git-context` logic.
2. Read [references/conventions.md](references/conventions.md) and discover
   branch naming, base ref, and whether the primary checkout is **pinned** to
   the default branch.

### Step 2 — Choose base and branch name

- **Base** — user-specified, else discovered default (`main` / `master` /
  `origin/main`). Fetch if needed: `git -C <path> fetch origin <base>` when
  tracking a remote base.
- **Name** — user-specified if given; else derive from issue/slug using project
  prefixes when known.

### Step 3 — Pinned-primary guard

If conventions say the primary checkout must stay on the default branch and the
resolved checkout **is** that primary:

- Do **not** `git switch -c` there for feature work.
- Tell the user and offer `kerpo-git-worktree-add` instead (which creates the
  branch with the worktree).

If the user explicitly insists on a branch on the primary anyway, confirm once,
then proceed.

### Step 4 — Create the branch

From the chosen checkout (after any guard):

```bash
git -C <checkout> rev-parse --verify <branch>  # must fail (not exist)
git -C <checkout> switch -c <branch> <base>
```

If the branch already exists locally or remotely, stop and report — do not
reset or force.

### Step 5 — Report

- Checkout path
- Branch name and base
- Whether primary stayed pinned (N/A if not applicable)

## Gotchas

- Prefer `git switch -c` over legacy `checkout -b`
- Creating a worktree is a different skill — if the user said “worktree”, use
  `kerpo-git-worktree-add` (it will create the branch if missing)
- Always `git -C <path>`; do not assume workspace root is the right checkout
