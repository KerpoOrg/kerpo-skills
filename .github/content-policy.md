# kerpo-skills — GitHub content policy

Learned from repo history on 2026-08-19 by `kerpo-gh-content-policy-learn`,
re-confirmed unchanged on 2026-08-23. Consumed by other `kerpo-gh-*` skills
so they follow this repo's local conventions instead of generic defaults.

## Evidence sampled

- All PRs (`gh pr list --state merged`): 1 total — a bot-generated Renovate
  onboarding PR (#3, merged via `Merge pull request #3` — the one exception
  to the direct-commit pattern below). No human-authored PR exists yet in
  this repo.
- All issues (`gh issue list --state all`): 3 total — 2 closed
  (`#1`, `#2`, both by @jounirajala), 1 open (`#4`, Renovate Dependency
  Dashboard, bot-generated).
- Commit history (`git log`): only one `Merge pull request` commit (the
  Renovate onboarding PR above) — all other work lands via direct commits to
  `main`, not a PR-merge workflow.
- No `.github/PULL_REQUEST_TEMPLATE*` or `ISSUE_TEMPLATE*` files existed
  before this policy was written.

**Caveat:** the PR sample size is 0 human PRs, so no real PR body/checklist
convention exists yet to learn from. The sections below distinguish observed
convention (issues) from proposed-but-unconfirmed convention (PRs).

## Issue body contract (observed, from #1 and #2)

Issues consistently use these headings, in this order:
1. `## Skill` — one line naming the new/changed skill
2. `## Problem / need` — why the gap exists, contrasted against neighboring
   skills to justify why it isn't scope creep
3. `## Proposed solution` — often split into **Do** / **Do not** sub-lists
   when the risk is over-triggering or duplicating another skill's job
4. `## Use cases` — concrete example prompts/scenarios
5. `## Additional context` — origin story, cross-skill intent tables, naming
   rationale

No checkboxes are used in issue bodies. Issues are closed manually/directly —
no `Closes #N` / `Fixes #N` keyword was observed in any commit message, and
no PR exists that could have closed one.

## PR body contract (not yet established — proposed defaults)

Because there is no real PR history to learn from, do not assume a checklist
or section structure is "the convention" here. If/when `kerpo-gh-*` skills
need to write a PR body in this repo, default to:
- Mirror the issue heading style above (`## Problem / need` /
  `## Proposed solution` framing) rather than inventing new section names.
- If a checklist is added (e.g. by `kerpo-gh-pr-checklist-maintain`), treat
  it as a fresh introduction, not a codified repo norm — revisit this policy
  once 3+ real human PRs exist.

## Linking contract

Not established. No commit or issue in this repo has used
`Closes/Fixes/Resolves #N`, because no PR has ever closed an issue here.
If a PR is opened, prefer `Closes #N` (GitHub's most common auto-link
keyword) unless the user specifies otherwise.

## Commit message style (observed)

Short imperative subject line (`Add kerpo-tdd skillset and fix trigger-test
script`, `Fix install task: clean build/ before pack...`). Release commits
follow `Release X.Y.Z with <feature summary>.`

## Safety rules

- Never uncheck an already-checked checkbox in a PR/issue body (forward
  guidance for when checklists appear — none exist yet).
- Never clobber user content outside owned marker sections
  (`<!-- kerpo-gh-content-policy-learn:start -->` / `:end`, or whatever
  marker convention a consuming skill introduces).
- Do not present the "proposed defaults" above as confirmed repo convention
  to the user — they are placeholders until real PR history exists.

<!-- kerpo-gh-content-policy-learn:start -->
<!-- kerpo-gh-content-policy-learn:end -->
