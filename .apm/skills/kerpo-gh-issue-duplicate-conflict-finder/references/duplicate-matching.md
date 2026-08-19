# duplicate-matching

Reference heuristics for `kerpo-gh-issue-duplicate-conflict-finder`.

## Owned section

The skill only edits the marker-delimited region it owns:

```html
<!-- kerpo:issue-dup-conflicts:start -->
... owned duplicates/related/conflicts content ...
<!-- kerpo:issue-dup-conflicts:end -->
```

Preserve everything outside these markers.

## Candidate selection signals

Use multiple signals to gather candidates, then de-duplicate:
1. Label/component overlap
   - same or overlapping area labels/components
2. Text similarity (best-effort)
   - title/body similarity via keyword overlap / lightweight fuzzy matching
3. Branch context / PR references (if available)
   - if the target issue is referenced by PRs, inspect those PRs for other
     related issues and use them as candidates

## Similarity classification (best-effort; avoid over-claiming)

Classify candidates into buckets:
- `Possible duplicates`
  - high similarity + same intended outcome / acceptance criteria
- `Partial duplicates`
  - related but the scope matches only a subset
- `Related (same theme)`
  - same area/component labels and overlapping problem wording, even if
    the outcome differs
- `Conflicts (contradictory direction)`
  - conflicting requirements or mutually exclusive acceptance criteria language
  - heuristic trigger words include: `must not`, `remove`, `opposite`,
    `instead`, `conflict`, `security`, `revert` (use sparingly)

If evidence is too weak:
- omit the candidate rather than guessing.

## “Why we think so” snippets

For each linked candidate, include a short reason that ties to the chosen
signals:
- “Same area label(s) + overlapping problem wording”
- “High title/body overlap; likely duplicates”
- “Shared context via referenced PRs; related”
- “Contradictory acceptance criteria language detected”

