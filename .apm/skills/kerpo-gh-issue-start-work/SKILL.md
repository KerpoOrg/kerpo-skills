---
name: kerpo-gh-issue-start-work
description: >-
  Use when the user is about to start working on a GitHub issue. Apply when the
  user says "I'm starting work on issue #N", "let's work on this issue", "pick
  up issue #N", or "take this issue". Claims the issue (assign + in-progress),
  then follows project worktree policy: create/enter a worktree when required,
  or ask the developer if unclear. Does not activate for creating issues,
  assigning without starting work (kerpo-gh-issue-assign), closing issues
  (kerpo-gh-issue-done), or human-only worktree cleanup
  (kerpo-git-worktree-clean).
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.1"
---
# kerpo-gh-issue-start-work

Claims a GitHub issue before work begins, then optionally sets up a branch /
worktree per **project conventions**. Never runs worktree cleanup.

## Instructions

### Step 1 — Resolve issue and repo

- **Issue number** — from user's message or current context
- **Repo** — from `git remote get-url origin` or user-specified

Fetch current issue state:
```
gh issue view <number> --repo <owner/repo> --json assignees,labels,title,state
```

### Step 2 — Check if already assigned

If the issue already has assignees, inform the user ("Issue #N is currently
assigned to @X — do you want to also assign yourself?") and wait for
confirmation before proceeding.

### Step 3 — Assign to current user

```
gh issue edit <number> --add-assignee @me --repo <owner/repo>
```

### Step 4 — Add in-progress label if it exists

Check available labels:
```
gh label list --repo <owner/repo>
```

If an `in-progress` (or `in progress`) label exists, add it:
```
gh issue edit <number> --add-label "in-progress" --repo <owner/repo>
```

If no such label exists, skip silently — do not create labels without asking.

### Step 5 — Worktree / branch policy

Discover start-work policy using
[references/conventions.md](references/conventions.md)
(layout, pinned primary, “start work → worktree?”).

| Policy | Action |
|---|---|
| **Require worktree** | Compose `kerpo-git-worktree-add` (create branch if missing) then `kerpo-git-worktree-enter` |
| **Root checkout OK** | Stop after claim unless the user also asked for a branch → then `kerpo-git-branch-create` |
| **Unclear** | **Ask the developer**: worktree, branch on current checkout, or claim-only? Wait for the answer before creating anything |

Branch/worktree naming: prefer project convention; else derive a short slug from
the issue title/number.

Do **not** invoke `kerpo-git-worktree-clean` here. You may note that the human
can ask to clean up the worktree later when finished.

### Step 6 — Confirm

Report:
- Issue title and number
- Assigned to @\<you\>
- Label added (or skipped)
- Checkout outcome: worktree path + branch, branch-only, claim-only, or waiting on ask

Example: "Issue #1 'Fix login bug' — assigned to @jounirajala, labeled
in-progress. Worktree `worktree/fix-login` on `fix/login` (policy: require worktree)."

## Gotchas

- Always check existing assignees first — overwriting someone else's assignment is disruptive
- `in-progress` label may not exist in every repo — skip gracefully if missing
- When policy is unclear, ask — do not guess worktree vs root
- Cleanup is human-triggered only (`kerpo-git-worktree-clean`)
- Verify the active `gh` account with `gh auth status` if the repo is org-scoped
