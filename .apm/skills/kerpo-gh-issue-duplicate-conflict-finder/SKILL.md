---
name: kerpo-gh-issue-duplicate-conflict-finder
description: >-
  Use when analyzing a GitHub issue to find likely duplicates, partial duplicates,
  related issues, and potential conflicts, then link candidates inside an
  owned marker section of the target issue body.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-issue-duplicate-conflict-finder

Finds likely duplicates/related/conflicting issues for a target GitHub issue
and writes the results into an owned marker-bounded section inside the issue
body.

## When to use
- “find duplicates for issue #N”
- “check issue #N for related/conflicting issues”
- “update this issue with possible duplicates”

## Apply when (GitHub-only gating)
- Operating on GitHub issues (target issue number/URL, and `gh` context).
- Repo appears GitHub-native.

## Instructions

### Step 1 — Gate: confirm GitHub context
1. Resolve repo (`owner/repo`) and target issue number from message/context.
2. Confirm GitHub-only context (`gh` present/authenticated; PR/issue context
   is GitHub).
3. If user is describing Jira-only or Bitbucket-only workflows, stop and ask
   for the GitHub issue to operate on.

### Step 2 — Fetch target issue
Fetch:
- issue title/body
- labels (and any “area/component” style labels)
- any explicit issue/PR references in the body (best-effort)

### Step 3 — Select candidate issues
Gather a candidate pool using multiple signals:
1. `labels_components`: overlapping labels/components in common (same area).
2. `text_similarity`: best-effort title/body similarity using keyword overlap
   and lightweight fuzzy heuristics.
3. `branch_context` / PR references:
   - if the target issue is referenced by PRs, inspect those PRs to
     discover other issues in the same PR context.

De-duplicate candidates by issue number.

### Step 4 — Classify candidates into buckets
Using `references/duplicate-matching.md`:
- `Possible duplicates`
- `Partial duplicates`
- `Related (same theme)`
- `Conflicts (contradictory direction)` (best-effort; avoid over-claiming)

If evidence is too weak for a bucket, omit the candidate.

### Step 5 — Update the target issue body (idempotent)
Edit inside the owned marker region:
- `<!-- kerpo:issue-dup-conflicts:start -->`
- `<!-- kerpo:issue-dup-conflicts:end -->`

If region is missing:
- insert fallback region with the four bucket headings.

Within the owned region:
- add bullet entries for candidates with:
  - issue URL
  - state (open/closed) if available
  - a short “why we think so” snippet

Removal/soft-expire:
- On subsequent runs, rewrite the owned region to reflect the
  *current* candidate set; do not keep stale bullets that no longer match
  the evidence.

### Step 6 — Optional cross-linking (after confirmation)
By default, only update the user-specified target issue(s).
If the user confirms bidirectional cross-linking:
- update candidate issues too (same marker region contract)
- keep the updates symmetric and de-duplicate entries
- if later evidence changes, remove stale bullets inside owned markers

### Step 7 — Confirm
Report:
- target issue number
- how many candidates were linked in each bucket
- mention the top 1-2 strongest matches (by evidence type)

## Gotchas
- Avoid inventing conflicts or duplicates with weak evidence.
- Preserve all user content outside the owned marker section.

