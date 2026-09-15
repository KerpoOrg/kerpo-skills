---
name: kerpo-git-worktree-enter
description: >-
  Use when the user wants the agent session to work inside an existing git
  worktree: move the Cursor agent root and verify checkout context. Apply when
  the user says "work in that worktree", "switch to the worktree", "enter
  worktree/foo", or "start coding in the linked worktree". Does not activate for
  creating worktrees (kerpo-git-worktree-add), creating branches only
  (kerpo-git-branch-create), human-only cleanup (kerpo-git-worktree-clean), or
  merely asking which worktree you are in (kerpo-git-context).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.1"
---
# kerpo-git-worktree-enter

Pins the agent session to an existing linked worktree so edits and terminals
target that checkout.

## Instructions

### Step 1 — Select the worktree

1. Resolve repo via `kerpo-git-context`.
2. `git -C <primary> worktree list --porcelain`
3. Pick the target from user path/name/branch. If ambiguous, list candidates and ask.

If the worktree does not exist and the user clearly wanted create+enter, compose
`kerpo-git-worktree-add` first, then continue here.

**Session-managed worktree check.** Follow
[references/conventions.md](references/conventions.md)
(“Session-managed worktrees”). If the session is already rooted in a linked
worktree (e.g. T3 Code, which roots each session in
`~/.t3/worktrees/<repo-slug>/<id>` on a `t3code/<slug>` branch) or
`KERPO_WORKTREE_MANAGEMENT=off` is set, **stop here**: the session cannot
re-root into another worktree without being restarted. Tell the user what
happened — e.g. "Session worktree managed by T3 Code — enter requires a new
session; staying in `<path>` on `<branch>`" — and, when the user really wants
another tree, let them restart there rather than composing add.

### Step 2 — Move agent root (Cursor)

Read [references/cursor-enter.md](references/cursor-enter.md).

Call **`move_agent_to_root`** with the worktree’s **absolute** path **before**
any file edits in that tree.

- Ordinary linked worktree / local path → `move_agent_to_root`
- Verbatim `cursorfs-clone` sibling on the same branch →
  `move_agent_to_cloned_root` only when that tool’s preconditions match

If `move_agent_to_root` is unavailable (non-Cursor), tell the user to open the
worktree folder as the workspace root, then continue with `git -C` verification.

### Step 3 — Verify

```bash
git -C <worktree-path> rev-parse --show-toplevel
git -C <worktree-path> rev-parse --abbrev-ref HEAD
git -C <worktree-path> status --short
```

Report path, branch, clean/dirty summary.

### Step 4 — Optional bootstrap

From [references/conventions.md](references/conventions.md): if the project
documents one-time setup for new checkouts (e.g. `mise trust`, env link), run
or propose those steps. Do not invent stack/env commands when undocumented.

## Gotchas

- Enter does not create branches or worktrees (except via explicit compose with add)
- Enter must never remove or clean worktrees
- Session already rooted in a linked worktree (e.g. T3 Code) or
  `KERPO_WORKTREE_MANAGEMENT=off` → entering another tree needs a session
  restart; stop and say so instead of composing add
- After moving root, prefer paths relative to the new root; still use `git -C`
  when multiple checkouts remain relevant
