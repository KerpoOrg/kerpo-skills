---
name: kerpo-gh-pr-issue-links
description: >-
  Use when updating GitHub PR and issue bodies so linked issues are kept in sync:
  the PR links to its issues (including explicit Closes/Fixes/Resolves text for
  GitHub auto-linking), and each issue links back to the PR plus a closure plan.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-pr-issue-links

Maintains PR↔issue link consistency and updates issue descriptions to show
which PRs they are connected to and what the PR is expected to close.

## When to use
- “link PR #N to its issue(s)”
- “update PR issue links for PR #N”
- “ensure issues mention this PR and expected closure”

## Apply when (GitHub-only gating)
- Operating on GitHub PRs/issues (via PR number/URL and `gh` context).
- Repo appears GitHub-native (e.g. `.github/` exists, or remote host is
  `github.com`).

## Instructions

### Step 1 — Gate: confirm GitHub context
1. Resolve repo (`owner/repo`) via `git remote get-url origin` if possible.
2. Confirm GitHub-only context:
   - prompt includes PR/issue numbers or URLs
   - `gh` is available/authenticated
3. If user describes Jira/Bamboo/GitLab as the primary system, stop and ask
   which GitHub PR/issue to update.

### Step 2 — Fetch PR and resolve linked issues
1. Fetch PR data:
   - number, body, title, state/draft
   - closing issue references (when available)
2. Compute candidate linked issue numbers from multiple sources:
   - GitHub computed `closingIssuesReferences` (best-effort)
   - Explicit `Closes/Fixes/Resolves #N` patterns in PR body
   - Branch name patterns like `issue-123-...`, `fix/123-...`, etc.
   - PR title patterns (rare; best-effort)
3. De-duplicate and normalize to a final set of issue numbers.

If the set is empty:
- If the user provided explicit issue numbers, use them.
- Otherwise ask the user before inventing links.

### Step 3 — Update PR body owned “Linked Issues” section
Edit inside:
- `<!-- kerpo:pr-issue-links:start -->` ... `<!-- kerpo:pr-issue-links:end -->`

Required content:
1. A short bullet list of linked issue URLs.
2. Explicit close keyword lines near the top of the owned section so GitHub
   can reliably display “Development / branches linked to issues”:
   - `Closes #123` / `Fixes #123` / `Resolves #123`
   - Prefer the policy keyword when available; else default to `Closes`.

Idempotency:
- Preserve content outside markers.
- De-duplicate URLs within the owned section.

### Step 4 — Update each linked issue body
For every linked issue number:
1. Fetch issue body.
2. Edit inside:
   - `<!-- kerpo:issue-linked-prs:start -->` ... `<!-- kerpo:issue-linked-prs:end -->`
   - `<!-- kerpo:issue-closure-plan:start -->` ... `<!-- kerpo:issue-closure-plan:end -->`
3. `Linked PRs` region:
   - include the PR URL and state marker (draft/open/merged).
4. `Closure Plan` region:
   - include the closure expectation in a stable sentence, e.g.
     “This PR is expected to close: #<issue-number>” plus any other
     additional closing references discovered for the PR.

De-duplication:
- If an entry exists already, keep it; do not add duplicates.
- If the final linked set shrinks, rewrite only within the owned markers.

### Step 5 — Confirm to user
Report:
- PR URL/number
- The issue numbers you linked
- Which files/sections were updated (PR owned section + per-issue marker sections)

## Gotchas
- Do not create labels or modify repo-wide templates without explicit user
  request.
- Don’t clobber outside-marker content.
- If links are ambiguous (cannot determine issue numbers reliably), ask.

