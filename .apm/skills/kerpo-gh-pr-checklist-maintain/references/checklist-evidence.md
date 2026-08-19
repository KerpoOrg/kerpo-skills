# checklist-evidence

This reference documents the evidence-based heuristics used by
`kerpo-gh-pr-checklist-maintain` to update checkbox items in a PR body.

## Owned checklist section

The skill updates only the marker-bounded region it owns:

```html
<!-- kerpo:pr-checklist:start -->
... owned checklist content ...
<!-- kerpo:pr-checklist:end -->
```

Outside this region, preserve user content exactly.

## Checkbox parsing

Inside the owned region, detect list items of the form:

- `[ ] <label text>`
- `[x] <label text>`

Treat each checkbox line as a separate checkbox item; preserve ordering.

## “Never uncheck” rule

If a checkbox is already `[x]`, the skill must not turn it back into `[ ]`
without an explicit user request.

For boxes that are `[ ]`, the skill may turn them into `[x]` if evidence
strongly suggests completion.

## Evidence heuristics

The skill may fetch PR evidence using `gh` (GitHub context) and updates
checkboxes only when it can justify them from evidence.

### 1) CI / required checks

If the checkbox label text contains any of:
- `ci`
- `check`
- `required checks`
- `tests passing` (or similar)

Then:
1. Run `gh pr checks <pr> --required` (or equivalent required-only listing).
2. Mark `[x]` only if required checks are successful.

### 2) Tests added/updated

If the checkbox label text contains any of:
- `test`
- `unit`
- `integration`
- `spec`

Then:
1. Fetch changed files for the PR.
2. Mark `[x]` if at least one changed file matches common test paths/names:
   - `tests/`, `test/`, `__tests__/`
   - `*.test.*`, `*.spec.*`

Optional (best-effort): also consider changed files in test folders even if
the label doesn’t explicitly say “test”.

### 3) Docs updated

If label text contains:
- `doc`
- `documentation`
- `readme`

Then:
1. Fetch changed files.
2. Mark `[x]` if at least one changed file matches:
   - `docs/`
   - `README*`
   - documentation extensions (e.g. `.md`)

### 4) Linked issue / linkage

If label text contains:
- `link`
- `issue`
- `closes`
- `fixes`

Then:
1. Determine whether the PR body includes explicit `Closes/Fixes/Resolves #N`
   text (keyword-based).
2. Mark `[x]` if at least one issue reference is present (or if the PR is
   already connected to an issue via computed closing references).

### 5) Implementation / code completion (fallback)

If label text contains:
- `implemented`
- `implementation`
- `code`
- `work complete`
- `done`

Then (weak heuristic):
1. Fetch changed files for the PR.
2. Mark `[x]` if there is at least one non-documentation code-change file
   (best-effort: ignore files under `docs/` if possible).

If evidence is ambiguous, leave as `[ ]` and do not guess.

## Fallback when checklist is missing

If the marker-bounded checklist region does not exist:
- Insert fallback owned checklist content using the policy defaults (if
  available).
- Otherwise insert a conservative default checklist with boxes based on
  the same evidence heuristics (so “already true” boxes can be checked on
  first run).

