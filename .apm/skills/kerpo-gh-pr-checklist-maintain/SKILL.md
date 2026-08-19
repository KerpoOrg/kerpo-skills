---
name: kerpo-gh-pr-checklist-maintain
description: >-
  Use when updating/syncing a GitHub PR description so the generated checklist
  checkboxes stay accurate over time (including after pushing commits) and are
  never left unchecked when PR evidence indicates completion.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-pr-checklist-maintain

Keeps a PR’s marker-bounded checklist checkboxes updated as the PR evolves.
This skill is GitHub-only (`kerpo-gh-*`) and must not leak into non-GitHub
systems.

## When to use
- “update PR #N checklist”
- “sync the checklist in PR #N”
- “fix/check/uncheck the checklist items in this PR description”

## Apply when (GitHub-only gating)
- Operating on GitHub PRs/issues and you have a GitHub PR number or context.
- The repo context appears GitHub-native (uses `gh`, has `.github/`, or git
  remote points at `github.com`).

## Instructions

### Step 1 — Gate: confirm GitHub context
1. Resolve repo:
   - Use git remote for `owner/repo` if available.
2. Confirm GitHub context:
   - `gh` exists in the environment, and user prompt mentions GitHub PRs.
3. If user describes Jira/GitLab-only workflows, stop and ask which GitHub
   PR/URL to operate on.

### Step 2 — Fetch PR and locate the owned checklist region
1. Resolve PR number from the message/context.
2. Fetch PR:
   - title, body
   - changed files list (via `gh pr view --json files` or equivalent)
3. Locate the owned checklist region:
   - Marker region:
     - `<!-- kerpo:pr-checklist:start -->`
     - `<!-- kerpo:pr-checklist:end -->`
4. If the region does not exist:
   - Insert fallback owned content (including the markers).
   - Use evidence heuristics to set initial boxes to `[x]` when
     confidently true; otherwise leave `[ ]`.

### Step 3 — Parse and update checkbox lines
1. Parse each checkbox line inside the owned region (`- [ ] ...` / `- [x] ...`).
2. Apply evidence-based heuristics (see `references/checklist-evidence.md`):
   - CI/required checks
   - tests/unit/spec changes
   - docs/readme changes
   - linked issue presence / `Closes/Fixes/Resolves`
   - implementation/code-change fallback (best-effort)
3. Never uncheck:
   - If a checkbox is already `[x]`, keep it `[x]` unless the user asks to
     correct it explicitly.
4. Update only checkbox text within the owned markers:
   - Preserve ordering and non-owned content.

### Step 4 — Write the updated PR description
Use `gh pr edit <number> --body-file <file>` (or equivalent) and only
modify the body region owned by this skill.

### Step 5 — Confirm
Report:
- PR URL/number
- Which checklist items you checked and why (short evidence summary)
- Which items remain `[ ]` due to missing/ambiguous evidence

## Gotchas
- Don’t clobber checklist sections outside the markers.
- Don’t auto-create labels or repo-wide checklist templates without user
  confirmation.
- If evidence is ambiguous, prefer leaving `[ ]` rather than guessing.

