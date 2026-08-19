# implementation-story

This reference defines the content contract for
`kerpo-gh-pr-implementation-notes`.

## Owned PR section

The skill writes inside a marker-bounded region it owns:

```html
<!-- kerpo:pr-implementation-notes:start -->
... implementation story ...
<!-- kerpo:pr-implementation-notes:end -->
```

Only replace this region; preserve user-authored content elsewhere.

## Story structure (stable headings)

Inside the owned region, prefer this structure:

1. **Original intent (from issue #N)**  
   - 3-6 bullets summarizing the business need + requested changes,
     extracted from the issue’s “intent/business need” sections.
2. **Implemented in this PR**  
   - 2-6 bullets describing what the PR actually did, tied to changed areas
     (file paths, PR title/body, linked issue references).
3. **Deviations / tradeoffs**  
   - If evidence indicates a mismatch: list deviations as bullets.
   - If evidence is strong and aligned: write a short sentence like
     “No significant deviations detected from issue intent based on file
     changes and PR metadata.”

## Evidence sources

The skill should prefer evidence that can be checked:
- linked issue body text (intent extraction)
- PR title/body (what it claims)
- PR changed files list / paths (what actually changed)
- PR number + any explicit linking in PR body

Avoid inventing details that are not supported by the evidence.

