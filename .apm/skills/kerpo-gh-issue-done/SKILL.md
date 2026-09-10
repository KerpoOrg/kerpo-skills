---
name: kerpo-gh-issue-done
description: >-
  Use when the user wants a formal GitHub issue closeout: check the issue
  format, record as-built deviations from the original request, then close
  the issue. Apply when the user says "this issue is done", "issue #N on
  valmis", "sulje issue muodollisesti", "mark this issue done", or "do the
  final checks on this issue". Discovers format from the consuming repo or a
  user-provided source and always reports that source. Related PR merge is
  not a gate. Does not activate for starting work — that's
  kerpo-gh-issue-start-work. Does not activate for assigning — that's
  kerpo-gh-issue-assign. Does not activate for merging or reviewing PRs, or
  a bare "close issue" without closeout checks.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gh-issue-done

Formal issue closeout: discover the issue format, check the body against it,
record as-built deviations, update the body, close the issue. This skill does
not own a template. Related PRs are informational only — do not wait for merge.

## Instructions

### Step 1 — Resolve issue and repo

- **Issue number** — from the user's message or current context
- **Repo** — from `git remote get-url origin` or user-specified

If the checkout is ambiguous (linked worktrees, multi-repo workspace), resolve
with `kerpo-git-context` first.

```
gh issue view <number> --repo <owner/repo> --json title,body,state,labels,assignees,comments,url
```

If `state` is `CLOSED`: report the URL and stop. Do not reopen.

### Step 2 — Linked PRs (informational)

List related PRs from the issue timeline or search. Record URL + state
(open / merged / draft). **Do not merge. Do not block closeout on merge.**

### Step 3 — Discover format source

Read [references/format-discovery.md](references/format-discovery.md) and follow
the search order. Tell the user the chosen **Format source** (path or
user-provided URL/file) and why it was chosen *before* editing or closing.

Never invent a house template. Check the body against the discovered source
only: required fields/sections, empty placeholders, checkboxes. Fill missing
pieces in that template's own language. Do not add sections the source does
not require.

### Step 4 — As-built vs original request

Compare the original request (whatever scope / acceptance / design fields the
source defines) to what was actually done, using:

- issue comments
- the local checkout if it belongs to this issue
- linked PRs, including still-open ones — evidence of work, not a merge gate
- linked PRs’ owned `Implementation notes` marker section (if present in
  the PR body) — prefer these as a structured “what we implemented”
  source when inferring deviations

Write deviations into the template's as-built / notes / implementation field
**if that field exists**. If it does not, put deviations in the close comment
only — do not invent a new body section. If as-built cannot be inferred, ask
the user before closing.

### Step 5 — Update and close

1. `gh issue edit <number> --body-file <file> --repo <owner/repo>` — preserve
   the discovered template structure
2. If an `in-progress` or `in progress` label is on the issue, remove it.
   Do not create labels.
3. Close:

```
gh issue close <number> --repo <owner/repo> --reason completed --comment "<body>"
```

Close comment must include:

- **Format source:** `<path | user-provided URL/file>` (+ why chosen)
- Format: OK / what was corrected
- Deviations: list or none
- Related PRs: URLs + state — not a merge requirement

Report the issue URL to the user.

## Gotchas

- Format source is mandatory in both the user summary and the close comment
- User override (file, URL, "use this template") always wins over repo files
- No format source: say so, do a minimal closeout (non-empty body, deviations
  in the close comment), or ask for an override if the body is too vague
- Already closed → stop; do not reopen
- `in-progress` may be missing — skip label removal if it is not on the issue
- Verify the active `gh` account with `gh auth status` if the repo is org-scoped
