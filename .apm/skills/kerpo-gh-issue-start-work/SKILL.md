---
name: kerpo-gh-issue-start-work
description: >-
  Use when the user is about to start working on a GitHub issue. Apply when the
  user says "I'm starting work on issue #N", "let's work on this issue", "pick
  up issue #N", or "take this issue". Ensures the issue is assigned to the
  current user before work begins. Does not activate for creating new issues,
  reviewing issues, or closing issues — formal closeout is
  kerpo-gh-issue-done.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-issue-start-work

Ensures a GitHub issue is properly claimed before work begins: assigns it to
the current user and adds an `in-progress` label if available.

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

### Step 5 — Confirm

Report:
- Issue title and number
- Assigned to @<you>
- Label added (or skipped)

Example: "Issue #1 'Fix login bug' — assigned to @jounirajala, labeled in-progress."

## Gotchas

- Always check existing assignees first — overwriting someone else's assignment is disruptive
- `in-progress` label may not exist in every repo — skip gracefully if missing
- This skill does not create a git branch; if the user also needs a branch, suggest `git checkout -b <branch-name>` separately
- Verify the active `gh` account with `gh auth status` if the repo is org-scoped
