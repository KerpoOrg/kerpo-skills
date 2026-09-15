---
name: kerpo-t3code-setup
description: >-
  One-time repository initialization for the T3 Code app: write t3.json,
  choose the GitHub account to use for this repository when gh has multiple
  logins, and install .t3code/ensure-gh-identity.sh so T3 worktree sessions
  always run with the right GitHub identity. Apply when the user says "set up
  this repo for t3code", "initialize t3 code for this project", "t3 setup",
  asks which GitHub profile a repo should use, or reports that creating a PR
  fails with a CreatePullRequest permissions error while commits and pushes
  work. Idempotent — safe to re-run. Apply also when the user mentions having
  several GitHub accounts, logins, or profiles and asks which one applies to
  a repository. Does not activate for creating,
  claiming, assigning, or closing GitHub issues (kerpo-gh-issue-*), GitHub
  bug or feature feedback (rfhub-feedback, kerpo-skills-feedback), git
  branch, worktree add/enter/clean (kerpo-git-*), expired tokens or gh
  credential refresh, or PR review/editing (kerpo-gh-pr-*).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-t3code-setup

Initializes any repository for T3 Code, idempotently, from the repo root.
The first concern is the GitHub identity trap: T3's "create PR" button uses
the token of gh's **active** account, while commits and pushes usually go
through an SSH key of a different account. With multiple gh logins the wrong
active account goes unnoticed until `gh pr create` fails with
`does not have the correct permissions to execute CreatePullRequest`.

This skill asks which account the repo uses, pins it per repo, and installs
a guard so every future T3 worktree session self-corrects. It is a scaffold
for later setup tasks (T3-, Cursor-, or Claude-specific); keep each task
small, idempotent, and additive.

## Instructions

### Step 0 — Idempotency promise

Every step must be safe to re-run: detect, then only create what is missing
or repair drift. Report what was already in place instead of rewriting it.

### Step 1 — Resolve repo root

```bash
git rev-parse --show-toplevel
git rev-parse --path-format=absolute --git-common-dir
```

`git config` writes go to the **common** config, shared by all linked
worktrees — one answer per repo, every T3 session worktree inherits it.

### Step 2 — Pin the GitHub account for this repo

Inspect gh's logins:

```bash
gh auth status
```

- **Zero accounts** → stop and tell the user to run `gh auth login`, then
  re-run this skill.
- **One account** → pin it (below); mention the pin so the user can object.
- **Multiple accounts** → read the current pin first:
  `git config t3code.ghAccount`. If it is already set, confirm with the user
  that it is still the right one. If unset, **ask the user** which account
  this repo should use — list the login names from `gh auth status` and wait
  for the answer. Do not guess, do not pick the active account silently.

Pin the answer (repo-local, not committed):

```bash
git config t3code.ghAccount <login>
```

Note for the user: gh's active account is a **global** setting; switching it
affects everything on the machine until switched back.

### Step 3 — Install the identity guard

Copy [references/ensure-gh-identity.sh](references/ensure-gh-identity.sh)
into the target repo:

```bash
mkdir -p .t3code
cp <skill-dir>/references/ensure-gh-identity.sh .t3code/ensure-gh-identity.sh
chmod +x .t3code/ensure-gh-identity.sh
```

If the file already exists and differs, show the diff and update it after
confirmation. The guard verifies (or with `--fix` repairs) that gh's active
account matches `git config t3code.ghAccount`.

### Step 4 — Wire t3.json

Read `t3.json` at the repo root if present. Merge in one script entry,
keeping every existing field and script untouched (the schema at
https://t3.codes/schema/t3.json is strict — no unknown fields):

```json
{
  "$schema": "https://t3.codes/schema/t3.json",
  "scripts": [
    {
      "name": "Ensure gh identity",
      "command": "./.t3code/ensure-gh-identity.sh --fix",
      "icon": "configure",
      "runOnWorktreeCreate": true
    }
  ]
}
```

If an equivalent identity script already exists, keep it. Offer to import
the script into T3's project settings ("From t3.json" menu in the T3 UI)
when the user is next in the app — t3.json alone does not register scripts,
T3 imports them from it.

### Step 5 — Verify and report

```bash
./.t3code/ensure-gh-identity.sh
```

Report:
- Pinned account for this repo (and where it is stored)
- Guard installed: `.t3code/ensure-gh-identity.sh` (new / unchanged / repaired)
- t3.json state (created / merged / already correct)
- Guard check result, and whether an active-account switch was needed

Remind the user to **commit `t3.json` and `.t3code/`** — session worktrees
check out the repo, so the files must be in git to exist in every worktree.

## Gotchas

- Multiple gh accounts: `gh pr list` can succeed while `gh pr create` fails —
  list needs only read access, create needs the account to have repo access.
  If the user reports this signature, run this skill.
- The pinned account lives in `.git/config` (not tracked) — cloning the repo
  elsewhere requires re-running the setup; the ask happens once per clone.
- `gh auth switch` is machine-global. After finishing work in a repo that
  needed a different account, other repos may need their guard to fix back.
- t3.json is decoded leniently but schema-validated; keep unknown fields out
  and keep the exact script schema (`name`, `command`, `icon`,
  `runOnWorktreeCreate`).
- T3 auto-runs only scripts marked `runOnWorktreeCreate: true`; setup tasks
  should be fast (< 30 s) and idempotent by design.
- Do not hardcode any login in the installed guard — the git config is the
  single source of truth, so the same template works in every repo.
