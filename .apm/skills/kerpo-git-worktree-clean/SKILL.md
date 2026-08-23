---
name: kerpo-git-worktree-clean
description: >-
  Use only when a human explicitly asks to clean up, remove, tear down, or prune
  git worktrees. Apply when the user says "clean up this worktree", "remove
  worktree/foo", "tear down worktrees", or "prune old worktrees". Discovers
  project pre-destroy teardown (stop dev servers, stack rm, etc.) before
  git worktree remove. Does not activate on PR merge, issue close, handoff,
  agent task completion, or prompts from other skills — never auto-run cleanup.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-git-worktree-clean

Removes linked worktrees **only when a human asked**. Runs project-documented
teardown before `git worktree remove`.

## Human-only gate (mandatory)

Proceed only if the **current user message** (or a clear follow-up in this
turn) requests cleanup/removal. Do **not** run because:

- A PR merged or an issue closed
- Another skill suggested cleanup
- The agent “finished” a feature
- Start-work / enter / add completed

Other skills may mention that this skill exists; they must not invoke it.

Read [references/safety.md](references/safety.md).

## Instructions

### Step 1 — Resolve targets

1. `kerpo-git-context` + `git worktree list --porcelain`
2. Identify which worktree(s) the user named. If “all old ones” / vague, list
   and get confirmation of each path before removing.
3. Discover conventions ([references/conventions.md](references/conventions.md)):
   pre-destroy order, reserved worktrees.

Refuse reserved trees unless the user named them explicitly in this request.

### Step 2 — Dirty gate

```bash
git -C <worktree-path> status --short
```

If dirty: report files and ask — commit, stash, discard, or abort. Do not
force-remove a dirty worktree without explicit user confirmation.

### Step 3 — Pre-destroy teardown

If the project documents teardown before destroy, run it **in order** from
inside that worktree when the docs say so (examples only — do not invent):

- stop dev servers for that checkout
- `mise run stack rm` / compose down for that project name

If **no** teardown is documented: skip Docker/mise invention; go to git remove.

### Step 4 — Remove worktree

```bash
git -C <primary> worktree remove <path>
git -C <primary> worktree prune
```

If remove fails (lock / in use), stop; suggest stopping processes using that
cwd, re-run teardown, retry. Do not `rm -rf` the directory unless the user
explicitly orders a force path and git remove already failed.

### Step 5 — Branch deletion (ask)

Deleting the local branch is **optional** and requires confirmation unless the
user already said to delete it. Prefer deleting only when merged into the
default branch. Never force-delete a remote branch unless the user explicitly
asks.

### Step 6 — Optional primary residue

If conventions require checking the primary checkout for leftover dirty files
after cleanup, run `git status` there and classify keepers vs disposable — do
not claim “cleanup done” while residue is unclassified when that policy exists.

### Step 7 — Report

For each removed tree: path, teardown ran (yes/what/skipped), branch kept or
deleted, any follow-ups for the human.

## Gotchas

- Human trigger only — see gate above
- Teardown before remove when documented; never skip a documented `stack rm`
  equivalent if the project requires it
- Do not tear down stacks or worktrees that are still in active use by another
  agent unless the user explicitly listed them
