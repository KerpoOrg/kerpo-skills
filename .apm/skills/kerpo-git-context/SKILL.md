---
name: kerpo-git-context
description: >-
  Use when you need to determine which git repository or worktree the current
  session is working in. Apply before any git operation where the correct
  checkout is ambiguous — linked worktrees, multi-repo workspaces, or when the
  user mentions a path that may not be the workspace root. Also apply when the
  user asks "which repo am I in", "what branch is this", or "find the right
  worktree". Does not activate for simple single-repo git operations where the
  working directory is unambiguous.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-git-context

Resolves which git repository or worktree is relevant to the current session
and reports the resolved context with reasoning.

## Instructions

### Step 1 — Collect context hints

Gather evidence about where the session is working:
- Paths or filenames the user explicitly mentioned
- The session's primary working directory (cwd / workspace root)
- Open files visible in the conversation, if any

### Step 2 — Resolve the repo

Starting from the most specific path the user mentioned (or cwd if none):

```
git -C <path> rev-parse --show-toplevel   → repo root
git -C <path> rev-parse --git-dir          → .git path (file if linked worktree, dir if main)
git -C <path> rev-parse --git-common-dir   → common .git dir (differs from --git-dir in linked worktrees)
git -C <path> rev-parse --abbrev-ref HEAD  → current branch
git -C <path> worktree list --porcelain    → all worktrees for this repo
```

A linked worktree is identified when `--git-dir != --git-common-dir`.

### Step 3 — Handle multi-repo workspaces

If the workspace root may contain multiple repos:
```
find <workspace-root> -name ".git" -maxdepth 3
```
For each found repo, check if the user's mentioned paths or open files fall under it.
Prioritize repos that contain mentioned paths; list others as secondary.

### Step 4 — Report resolved context

Tell the user:
- **Checkout path** — the worktree root
- **Type** — main worktree or linked worktree
- **Branch** — current branch name
- **Reason** — why this checkout was chosen (e.g. "matches your cwd", "contains the file you mentioned")
- If multiple repos are relevant, list each with the same fields

If context is ambiguous after these steps, ask the user to clarify before proceeding.

## Gotchas

- In a linked worktree, `.git` is a **file** (pointer), not a directory — do not assume `.git/` is always a directory
- `git -C <path>` is safer than `cd && git` — it avoids changing the agent's working directory
- `find` with `-maxdepth 3` prevents scanning deep into `node_modules` or build dirs — adjust if workspace is deeply nested
- Submodules also have `.git` files — distinguish them from worktrees by checking if `worktree list` includes the path
