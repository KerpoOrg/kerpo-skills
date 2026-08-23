---
name: kerpo-gh-dep-bot-pr
description: >-
  Use when triaging or handling GitHub dependency-bot PRs (Renovate first;
  Dependabot and other flavours extensible): scrape changelogs, analyze
  migration needs from local package usage, and decide whether to merge after
  CI, fix on the PR branch, or open a migration issue for a major framework
  bump. Apply when the user says "handle renovate PR", "triage dependency
  PRs", "analyze this dep bump", "fix the renovate branch", "can we merge
  this dependency-bot PR after CI", "merge the Renovate PR", or "open a
  migration issue for the major framework bump PR". Does not activate for
  non-GitHub bots (Jira/GitLab/Bitbucket), Dependency Dashboard-only checkbox
  clicks without a PR, or generic feature/code review unrelated to dependency
  updates.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-dep-bot-pr

Safely triages GitHub dependency-bot PRs. **v1 fully supports Renovate**;
Dependabot is a documented stub. Flavour adapters live under
[references/flavours.md](references/flavours.md).

Semver alone is never enough: scrape changelogs, scan local usage, read
package special instructions, then classify impact. Merge / branch fix /
migration issue all require **explicit user confirmation**.

## When to use

- “handle renovate PR #N”
- “triage open Renovate / dependency-bot PRs”
- “analyze migration for this dep bump”
- “fix the renovate PR branch for breaking imports”

## Apply when (GitHub-only gating)

- GitHub PRs via `gh` and a GitHub-native repo (`.github/` or `github.com` remote).
- If the user describes Jira / GitLab / Bitbucket only, stop and ask for the
  GitHub PR/URL.

## Modes

1. **Single PR** — full analysis on one PR number/URL.
2. **Queue** — list open dep-bot PRs; run full changelog/usage analysis only
   for PRs the user selects (or a small top-N they approve) to control cost.

## Instructions

### Step 1 — Gate: confirm GitHub context

1. Resolve `owner/repo` from `git remote get-url origin` or user input.
2. Confirm `gh` is available/authenticated.
3. Non-GitHub systems → near-miss; do not proceed.

### Step 2 — Resolve PR(s)

- Single: `gh pr view <n> --json number,title,body,author,headRefName,labels,isDraft,url,files,state`
- Queue: search Renovate heads / authors, e.g. PRs with `head:renovate/` or
  author matching renovate; list number, title, draft, checks summary.

Reject PRs that are not from a known dep-bot flavour (see flavours).

### Step 3 — Detect flavour and parse packages

Read [references/flavours.md](references/flavours.md).

1. Run flavour `detect` (Renovate first; then Dependabot stub).
2. Run `parse` → normalized `DepUpdate` (packages, updateKind, grouped, security).
3. If flavour is Dependabot stub or `unknown` → fail closed to **review**;
   do not recommend `merge_ok`.

### Step 4 — Migration analysis

Read [references/migration-analysis.md](references/migration-analysis.md).

For each package in the PR:

1. **Scrape changelogs** (`from` → `to`) — prefer links in the PR body, then
   releases / CHANGELOG, then registry repo URLs. Missing changelog → cannot
   claim `merge_ok`.
2. **Scan local usage** — imports, config references, API call sites.
3. **Special instructions** — MIGRATION.md / UPGRADING.md / upgrade guides /
   high-impact ecosystem notes.
4. Build an **impact map** and classify overall impact: `none` | `small` | `major`
   (grouped PRs = worst package wins).

### Step 5 — Safety gates + CI

Read [references/safety-policy.md](references/safety-policy.md).

Combine impact with:

- draft / conflicts
- required checks (`gh pr checks` or equivalent)
- high-risk package list
- security labels

Decide action class:

| Decision | Meaning |
|----------|---------|
| `merge_ok` | Impact `none` + gates pass + CI green |
| `wait_ci` | Would be mergeable pending checks |
| `fix_on_branch` | Impact `small` — localized fixes on the bot PR branch |
| `major_migration` | Impact `major` — separate GitHub issue; block merge |
| `review` | Ambiguous / missing data / unknown flavour — human review |
| `reject` | Checks failed or unsafe — leave open; explain |

### Step 6 — Report (before any mutation)

Always report:

- Flavour + packages (from → to) + updateKind
- Changelog summary (breaking / migrations)
- Usage impact map (files / APIs)
- CI / draft / conflict status
- Recommended decision + rationale
- What you will do only after confirmation

**Do not** merge, approve, push, or create issues until the user confirms.

### Step 7 — Act on confirmation only

#### `merge_ok`

```
gh pr merge <n> --auto --squash --repo <owner/repo>
```

- Never `--admin` / force.
- `gh pr review --approve` only if the user asked or branch rules require it
  and they confirmed approval.

#### `fix_on_branch`

1. If checkout is ambiguous, use `kerpo-git-context`.
2. `gh pr checkout <n>`
3. Apply minimal fixes from the impact map.
4. Run known repo checks (test/typecheck) when discoverable; otherwise state
   what was skipped.
5. Commit on the PR branch; push so CI re-runs.
6. Re-evaluate gates; recommend `merge --auto` only if green again.

Prefer fixing the bot PR in place — do not open a parallel human PR unless
asked.

#### `major_migration`

1. `gh issue create` with: dep PR URL, packages from/to, changelog summary,
   usage impact map, migration plan / acceptance criteria, and
   **do not merge the dep PR until this issue is done**.
2. Optionally comment on the dep PR with the issue URL (“blocked on migration”).
3. Do not implement the large refactor in this skill unless the user explicitly
   pivots to that issue.

## Gotchas

- Semver patch/minor is a hint only — changelog + usage decide `merge_ok`.
- Missing changelog or failed usage scan → fail closed (no `merge_ok`).
- Never silent merge, silent push, or silent issue creation.
- Do not edit `renovate.json` automerge settings in this skill.
- Do not approve Dependency Dashboard checkboxes without explicit user intent.
- GitHub-only: never operate on Jira/GitLab/Bitbucket dependency UIs.
