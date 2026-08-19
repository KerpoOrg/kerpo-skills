# linking

Reference conventions for `kerpo-gh-pr-issue-links`.

## Owned sections (idempotent)

The skill must only edit marker-bounded regions it owns.

### PR body
Use this marker-bounded region inside the PR description:

```html
<!-- kerpo:pr-issue-links:start -->
... owned “Linked Issues” content ...
<!-- kerpo:pr-issue-links:end -->
```

### Issue body
For each linked issue, edit these two marker-bounded regions:

```html
<!-- kerpo:issue-linked-prs:start -->
... owned “Linked PRs” content ...
<!-- kerpo:issue-linked-prs:end -->
```

```html
<!-- kerpo:issue-closure-plan:start -->
... owned “Closure Plan” content ...
<!-- kerpo:issue-closure-plan:end -->
```

## Explicit close keywords for GitHub auto-linking

To make GitHub’s “Development / branches linked to issues” UI work
reliably, the PR description should contain explicit text of the form:

- `Closes #<issue-number>`
- `Fixes #<issue-number>`
- `Resolves #<issue-number>`

These should appear near the top of the owned “Linked Issues” section.

The keyword to prefer (Closes vs Fixes vs Resolves) should follow the learned
project policy when available; otherwise default to `Closes`.

## De-duplication rules

- Never duplicate issue/PR URLs inside the owned markers.
- Preserve any content outside markers.
- If a linked set shrinks (new evidence contradicts old links):
  - rewrite the owned marker regions to the new canonical set
  - do not touch content outside the owned markers.

