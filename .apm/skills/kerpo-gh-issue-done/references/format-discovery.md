# Format discovery

This skill does not own an issue template. Discover the format from the
**consuming repo** (where the skill is installed) or from a **user-provided**
source. Always tell the user what the check is based on.

## Search order

First strong match wins. If later sources also match, mention them but do not
switch unless the chosen source clearly does not fit this issue's body.

1. **User override** — always wins.
   - User names a file, URL, paste, or "use this template".
   - Fetch/read that source. Cite it as given (path or URL).
   - This is how an external system participates in v1 (no Linear/Jira API).

2. **GitHub issue templates in the consuming repo**
   - Look in `.github/ISSUE_TEMPLATE/` for `*.md` and `*.yml` / `*.yaml`
     (GitHub Issue Forms).
   - Pick the template whose fields or headings best match **this** issue's
     body (form field ids, markdown `##` headings, or `name:` / `title:`).
   - Cite the template path, e.g. `.github/ISSUE_TEMPLATE/bug.yml`.

3. **Agent rules in the consuming repo**
   - Search for issue-format guidance, for example:
     - `.cursor/rules/` files whose names or bodies mention issue creation,
       issue templates, or issue maturity
     - `AGENTS.md`, `CLAUDE.md`
     - other `*issue*creation*`, `*issue*template*`, `*maturity*` hits
   - Read only the section that defines issue body shape or closeout gates.
   - Cite the file path (and heading if useful).

If **both** (2) and (3) exist: use the source that **matches this issue's
current body**. Report the other as present, e.g. "Using X; repo also has Y."

## No source

If nothing matches:

- Say so: no format source in the consuming repo, no user override.
- Do **not** invent a house template or extra body sections.
- Minimal closeout: non-empty title/body; put as-built deviations in the
  close comment only.
- If the body is too vague to judge as-built vs original request, ask the
  user for an override before closing.

## Format source line (required)

Every user summary and every close comment includes:

```
Format source: <path | user-provided URL/file> — <one-line reason>
```

Examples:

```
Format source: .github/ISSUE_TEMPLATE/feature.yml — issue body field ids match this form
Format source: .cursor/rules/github-issue-creation.mdc — body headings match the rule's template
Format source: user-provided https://example.com/issue-shape.md — override
Format source: none — no template or agent rule found in the consuming repo
```

## Checking against the source

From the chosen source, extract the required fields/sections, placeholder
rules, and checkbox expectations **as that source defines them**. Then:

- Empty or placeholder-only required fields fail until filled in the source's
  own wording.
- Do not add fields the source does not require.
- Prefer filling gaps in the issue body over closing with a broken shape.

## As-built field

If the source has a field for as-built / implementation notes / deviations,
update that field. Otherwise write deviations only in the close comment.

## Close comment template

```markdown
Format source: <path | URL | none> — <why chosen>

Format: OK | corrected: <what changed in the body>

Deviations from original request:
- none
- or bullet list (scope, behavior, omitted work)

Related PRs (not a merge gate):
- <url> (<open|merged|draft>)
```
