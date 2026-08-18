---
name: kerpo-gh-issue-assign
description: >-
  Use when the user wants to assign a GitHub issue to themselves or someone else.
  Apply when the user says "assign this issue to me", "assign issue #N", or
  "add me as assignee". Defaults to the current authenticated GitHub user if no
  assignee is specified. Does not activate for creating issues, closing issues,
  or general GitHub project management unrelated to assignment.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-issue-assign

Assigns a GitHub issue to one or more users, defaulting to the current
authenticated user.

## Instructions

### Step 1 — Resolve parameters

Determine:
- **Issue number** — from the user's message or current context
- **Repo** — from current git remote (`git remote get-url origin`) or user-specified
- **Assignee(s)** — default `@me` (current authenticated user); use whatever the user specifies

### Step 2 — Assign

```
gh issue edit <number> --add-assignee <assignee> --repo <owner/repo>
```

For multiple assignees, pass `--add-assignee` once per person.

### Step 3 — Confirm

Report: "Issue #N assigned to @<user> in <owner/repo>."

## Gotchas

- `@me` resolves to the currently active `gh` account — verify with `gh auth status` if unsure which account is active
- If repo cannot be resolved from git remote, ask the user before guessing
- Does not remove existing assignees — use `--remove-assignee` explicitly if that is needed
