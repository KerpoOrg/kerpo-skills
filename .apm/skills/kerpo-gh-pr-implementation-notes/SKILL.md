---
name: kerpo-gh-pr-implementation-notes
description: >-
  Use when updating a GitHub PR description so it tells a clear “fulfillment story”:
  the original issue intent (business need) and what was implemented, plus any
  deviations/tradeoffs. Updates only the marker-owned section in the PR body.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-pr-implementation-notes

Writes/refreshes PR implementation notes as a story aligned with the original
issue intent.

## When to use
- “update implementation notes in PR #N”
- “make PR #N description tell the fulfillment story of the issue”
- “add implementation notes to this PR”

## Apply when (GitHub-only gating)
- Operating on GitHub PRs/issues (GitHub context and PR number/URL).
- Repo appears GitHub-native (`gh`, `.github/`, or GitHub remote).

## Instructions

### Step 1 — Gate: confirm GitHub context
1. Resolve repo + PR number from message/context.
2. Confirm `gh` GitHub context.
3. If user describes Jira/Bamboo/GitLab-only workflows, stop and ask for the
   GitHub PR/URL to update.

### Step 2 — Resolve issue intent for the PR
1. Determine linked issue(s) for this PR:
   - prefer PR’s own owned “Linked Issues” marker section (if present)
   - else use PR computed closing references / explicit `Closes/Fixes/Resolves`
   - else if still missing, ask the user or fall back to PR title/body as the
     “intent source”
2. Fetch the issue body (for each linked issue) and extract “intent” using
   heuristics:
   - Look for headings like: “Problem / need”, “What I was trying to do”,
     “Business need”, “Acceptance criteria”, “Goal”.
   - Use 3-6 concise bullets summarizing business need + requested changes.

### Step 3 — Analyze PR evidence (what it actually did)
Fetch evidence:
- PR title/body
- PR changed files list/paths
- PR labels (optional, best-effort)

Use changed paths to summarize what was implemented (2-6 bullets).

### Step 4 — Write/refresh the owned “Implementation notes” section
Owned marker region:
- `<!-- kerpo:pr-implementation-notes:start -->`
- `<!-- kerpo:pr-implementation-notes:end -->`

If the marker region does not exist:
- insert fallback owned section using the story headings.

Write content with this stable contract:
1. **Original intent (from issue #N)**
2. **Implemented in this PR**
3. **Deviations / tradeoffs**

Deviations:
- Only claim deviations when evidence suggests a mismatch.
- If no mismatch is supported: write a short sentence indicating alignment
  (avoid inventing tradeoffs).

Idempotency:
- Only replace inside the owned marker region; preserve the rest of the PR
  description.

### Step 5 — Confirm to user
Report:
- Which PR was updated
- Which issue(s) were used as intent sources
- Whether deviations were detected (and a 1-line summary)

## Gotchas
- Don’t clobber unrelated PR content outside markers.
- Don’t invent intent or implementation details that aren’t supported by
  issue text and PR file changes.

