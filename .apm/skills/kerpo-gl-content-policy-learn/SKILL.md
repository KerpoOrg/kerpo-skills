---
name: kerpo-gl-content-policy-learn
description: >-
  Use when the user wants to learn a project's merge request/issue/comment
  content conventions from repo history (GitLab only), and generate a
  project-level content-policy document that other skills can follow. Apply
  when the user says "learn MR conventions from this repo", "generate a
  content policy from GitLab history", or "create a policy for GitLab merge
  requests and issues". Does not activate for GitHub PRs/issues (that's
  kerpo-gh-content-policy-learn), or Jira/Bitbucket/Bamboo workflows.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gl-content-policy-learn

Creates/updates a project-level content policy for GitLab merge requests,
issues, and comments by "learning" from existing repo history. Intended to be
consumed by other `kerpo-gl-*` skills so they follow local conventions
(section names, checklists, linking keywords, tone).

## When to use
- User asks to "learn MR/issue conventions from this repo"
- User asks to "generate a content policy from GitLab history"
- User asks to "create a policy for GitLab merge requests and issues"

## Apply when (GitLab-only gating)
- The target repo appears to be hosted on GitLab and you're operating on
  GitLab merge requests/issues (via `glab` CLI context).

## Instructions

### Step 1 — Gate: confirm this is GitLab-only
1. Resolve the repo:
   - Use current git remote (`git remote get-url origin`) if available.
2. Confirm GitLab context:
   - `glab` is available and authenticated (or the user explicitly provides
     `--repo group/project` context).
   - Repo looks GitLab-native (e.g. remote host is `gitlab.com` or a
     self-hosted GitLab instance, or has `.gitlab/` / `.gitlab-ci.yml`).
3. If the user is describing GitHub/Jira/Bamboo/Bitbucket workflows only,
   stop and ask which GitLab repo/MR/issue to operate on. GitHub PRs/issues
   are `kerpo-gh-content-policy-learn`'s job, not this skill's.

### Step 2 — Sample existing conventions
Collect evidence (small, recent windows are enough):
- Recent merged MRs (e.g. `glab mr list --state merged --limit 20`):
  - MR titles, descriptions, and section headings
  - checklist/checkbox usage patterns (if present)
  - how MRs reference issues (e.g. `Closes/Fixes/Resolves #N`, or GitLab's
    `Closes #N` in the description vs a linked "Related issues" field)
  - draft/WIP conventions (`Draft:` prefix)
- Recent issues (e.g. `glab issue list --limit 20`):
  - "business need / intent" phrasing and section headings
  - acceptance criteria fields
  - label and milestone usage patterns
  - any existing "linked MRs" section (if present)
- Commits:
  - message subject format and ticket refs/prefixes (if any)
- MR review/discussion notes (if accessible):
  - tone and structure (inline vs summary, code fences, thread-resolution
    conventions)

If some evidence cannot be fetched, proceed with what is available and tell
the user what was skipped.

### Step 3 — Synthesize a policy document
Generate a single policy doc with these sections (adapt wording/structure to
what you observed):
1. MR description contract
   - Required/typical headings
   - Checklist patterns (how to structure checkboxes so skills can update them)
   - Owned-marker conventions (if the repo uses markers, reuse them; otherwise
     propose marker conventions but do not invent sections that the repo
     clearly doesn't use)
2. Issue description contract
   - Where "intent/business need" lives
   - Where as-built/implementation deviations live (if any)
3. Linking contract
   - Preferred keywords for issue closure in MR text (GitLab recognizes
     `Closes`, `Fixes`, `Resolves` for issues, plus its own "closes" pattern
     across cross-project references with `group/project#N`) and the
     expected placement
4. Comment/review style (optional)
   - Code block formatting preferences and tone
   - Thread-resolution conventions (who resolves discussions, when)
5. Safety rules
   - "Never uncheck an already-checked box" (if checkboxes exist in repo)
   - "Never clobber user content outside owned markers"

### Step 4 — Write the policy to tooling-appropriate locations
Detect and write to the following targets (write to all that exist; write to
`.gitlab/content-policy.md` as universal fallback):
- `.cursor/rules/gl-content-policy.mdc` (if `.cursor/` exists)
- `CLAUDE.md` or `.claude/CLAUDE.md` (append/maintain a policy section)
- `.kiro/policies/gl-content-policy.md` (if `.kiro/` exists)
- `.gitlab/content-policy.md` (create if missing)

Use idempotent markers in each target file:
- `<!-- kerpo-gl-content-policy-learn:start -->`
- `<!-- kerpo-gl-content-policy-learn:end -->`

Replace only the marker-bounded section; leave everything else untouched.

### Step 5 — Confirm to user
Report:
- What evidence windows you used (e.g. MRs merged last 20, issues last 20, etc.)
- Which files you updated/created
- 3-6 extracted conventions in plain language (so the user can sanity-check)

## Gotchas
- Do not write a policy if the repo/context is clearly not GitLab.
- `glab` and `gh` share similar verb shapes (`list`, `view`, `mr`/`pr`) but
  are not interchangeable — do not fall back to `gh` when `glab` is missing;
  ask the user to install/authenticate `glab` instead.
- GitLab calls them "merge requests" (MRs), not "pull requests" (PRs) —
  keep that terminology in the generated policy and in any headings it
  proposes, even if the repo also has GitHub mirrors.
- Never overwrite unrelated policy text outside the marker section.
- If the repo has multiple conventions, prefer the most frequent/most recent.
