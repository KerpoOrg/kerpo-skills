---
name: kerpo-gh-content-policy-learn
description: >-
  Use when the user wants to learn a project’s PR/issue/comment content
  conventions from repo history (GitHub only), and generate a project-level
  content-policy document that other skills can follow.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-content-policy-learn

Creates/updates a project-level content policy for GitHub PRs, issues, and
comments by “learning” from existing repo history. Intended to be consumed by
other `kerpo-gh-*` skills so they follow local conventions (section names,
checklists, linking keywords, tone).

## When to use
- User asks to “learn PR/issue conventions from this repo”
- User asks to “generate a content policy from repo history”

## Apply when (GitHub-only gating)
- The target repo appears to be hosted on GitHub and you’re operating on
  GitHub PRs/issues (via `gh` CLI context).

## Instructions

### Step 1 — Gate: confirm this is GitHub-only
1. Resolve the repo:
   - Use current git remote (`git remote get-url origin`) if available.
2. Confirm GitHub context:
   - `gh` is available and authenticated (or the user explicitly provides
     `--repo owner/name` context).
   - Repo looks GitHub-native (e.g. has `.github/` folder, or remote host is
     `github.com`).
3. If the user is describing Jira/Bamboo/GitLab workflows only, stop and ask which
   GitHub repo/PR/issue to operate on.

### Step 2 — Sample existing conventions
Collect evidence (small, recent windows are enough):
- Recent merged PRs (e.g. last 20):
  - PR titles, bodies, and section headings
  - checklist/checkbox usage patterns (if present)
  - how PRs reference issues (e.g. `Closes/Fixes/Resolves #N`)
- Recent issues (e.g. last 20):
  - “business need / intent” phrasing and section headings
  - acceptance criteria fields
  - any existing “linked PRs” sections (if present)
- Commits:
  - message subject format and ticket refs/prefixes (if any)
- PR review comments (if accessible):
  - tone and structure (inline vs summary, code fences, etc.)

If some evidence cannot be fetched, proceed with what is available and tell
the user what was skipped.

### Step 3 — Synthesize a policy document
Generate a single policy doc with these sections (adapt wording/structure to
what you observed):
1. PR body contract
   - Required/typical headings
   - Checklist patterns (how to structure checkboxes so skills can update them)
   - Owned-marker conventions (if the repo uses markers, reuse them; otherwise
     propose marker conventions but do not invent sections that the repo clearly
     doesn’t use)
2. Issue body contract
   - Where “intent/business need” lives
   - Where as-built/implementation deviations live (if any)
3. Linking contract
   - Preferred keywords for issue closure in PR text (`Closes` vs `Fixes` vs
     `Resolves`) and the expected placement
4. Comment/review style (optional)
   - Code block formatting preferences and tone
5. Safety rules
   - “Never uncheck an already-checked box” (if checkboxes exist in repo)
   - “Never clobber user content outside owned markers”

### Step 4 — Write the policy to tooling-appropriate locations
Detect and write to the following targets (write to all that exist; write to
`.github/content-policy.md` as universal fallback):
- `.cursor/rules/gh-content-policy.mdc` (if `.cursor/` exists)
- `CLAUDE.md` or `.claude/CLAUDE.md` (append/maintain a policy section)
- `.kiro/policies/gh-content-policy.md` (if `.kiro/` exists)
- `.github/content-policy.md` (create if missing)

Use idempotent markers in each target file:
- `<!-- kerpo-gh-content-policy-learn:start -->`
- `<!-- kerpo-gh-content-policy-learn:end -->`

Replace only the marker-bounded section; leave everything else untouched.

### Step 5 — Confirm to user
Report:
- What evidence windows you used (e.g. PRs merged last 20, issues last 20, etc.)
- Which files you updated/created
- 3-6 extracted conventions in plain language (so the user can sanity-check)

## Gotchas
- Do not write a policy if the repo/context is clearly not GitHub.
- Never overwrite unrelated policy text outside the marker section.
- If the repo has multiple conventions, prefer the most frequent/most recent.

