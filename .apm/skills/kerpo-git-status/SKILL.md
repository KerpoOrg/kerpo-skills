---
name: kerpo-git-status
description: >-
  Use when the user wants to see uncommitted or untracked files in their current
  git checkout. Apply when the user asks "what files have I changed", "show me
  dirty files", "what's uncommitted", "are there untracked files", or similar.
  Handles linked worktrees and multi-repo workspaces correctly by first resolving
  which checkout is relevant. Does not activate for git log, git diff of specific
  commits, branch management, or non-git file listing.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-git-status

Reports untracked and uncommitted files for the correct git checkout, handling
linked worktrees and multi-repo workspaces.

## Instructions

### Step 1 — Resolve context

Use the `kerpo-git-context` skill logic to determine which checkout(s) are relevant.
If context was already resolved earlier in the conversation, reuse it.

### Step 2 — Collect dirty-state per checkout

For each resolved checkout path, run:

```
git -C <checkout-path> status --short
git -C <checkout-path> ls-files --others --exclude-standard
```

`status --short` output codes:
- `M ` or ` M` — modified (staged / unstaged)
- `A ` — new file staged
- `??` — untracked
- `D ` or ` D` — deleted

### Step 3 — Report

Group results by checkout if multiple repos are involved. For each checkout report:

1. **Staged changes** (index vs HEAD) — if any
2. **Unstaged changes** (working tree vs index) — if any
3. **Untracked files** — if any
4. Summary line: "2 staged, 1 unstaged, 3 untracked in `feature/foo` at `~/proj/worktrees/feature`"

If everything is clean: "Working tree clean in `main` at `~/proj`."

If untracked files exceed 20, summarize: "23 untracked files — run `git status` for the full list."

## Gotchas

- Always run `git -C <checkout-path>`, never from workspace root — that is the whole point of this skill
- Staged and unstaged changes are different things: report them separately so the user knows what will go into the next commit
- Submodule dirty state is not reported by default; mention it only if the user asks
