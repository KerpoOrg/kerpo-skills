---
name: kerpo-gha-workflow-validate
description: >-
  Use when auditing or validating GitHub Actions workflows against the kerpo
  baseline: actionlint + zizmor, permissions review, SHA pinning, template
  injection (${{ }} in run:), timeout-minutes, concurrency, cache hygiene,
  naming conventions. Apply when the user says "audit our workflows", "are our
  workflows secure", "check CI quality", "validate github workflows".
  Report-only, errors first then warns; suggests composing
  kerpo-gha-workflow-refactor when fixes are wanted. Does not activate for
  creating (kerpo-gha-workflow-create), refactoring
  (kerpo-gha-workflow-refactor), or auditing your own action library
  (kerpo-gha-action-library).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gha-workflow-validate

Audits `.github/workflows/**` and `.github/actions/**` against the kerpo
baseline. Reports findings; does **not** edit files. When the user wants
fixes, compose `kerpo-gha-workflow-refactor`.

## When to use

- "Audit our workflows against best practices."
- "Are our GitHub Actions secure?"
- "Run actionlint/zizmor over `.github/workflows` and tell me what's broken."
- "Check CI quality" / "validate github workflows".
- Negative: "fix the vulnerabilities" -> refactor (validate stays
  report-only); "add CI" -> create.

## Instructions

1. Resolve the repo root (compose `kerpo-git-context` if ambiguous).
2. Read [references/gha-security-baseline.md](references/gha-security-baseline.md)
   and [references/gha-naming-conventions.md](references/gha-naming-conventions.md).
3. Run the static tools when available:
   - `actionlint` over the workflow files.
   - `zizmor .` for security analysis.
   - `shellcheck` on any inline `run:` scripts extracted for review (or on the
     repo's scripts), where practical.
   - Optional: `mpdude/action-validator` for schema validation.
4. Walk the checklist below; record each finding with file, line, severity
   (error/warn), and a one-line reason.
5. Report errors first, then warns, then an info summary. Suggest
   `kerpo-gha-workflow-refactor` when errors exist. Never edit files silently.

## Checklist

Errors:

- [ ] Third-party `uses:` not pinned to a full SHA (branch/`@main`/bare major)
- [ ] Missing top-level `permissions:` (inherits broad default)
- [ ] Untrusted `${{ }}` (PR title, branch, commit message, issue body) used
      inside `run:`
- [ ] `pull_request_target` combined with a fork-head checkout
- [ ] Static long-lived cloud credentials where OIDC is available
- [ ] Secret value, token, or key committed in a workflow

Warns:

- [ ] Missing `timeout-minutes` on a job (default is 360)
- [ ] Missing or unscope `concurrency` on a PR/build workflow
- [ ] No cache for a lockfile-based install (or cache key not lockfile-based)
- [ ] `secrets: inherit` to a reusable workflow that does not need it
- [ ] Required workflow missing `merge_group` while a merge queue is enabled
- [ ] `actions/upload-artifact` reusing a name across matrix legs
- [ ] Names not kebab-case (ids/inputs) or UPPER_SNAKE (`env`/secrets)
- [ ] `secrets`/`vars` shadowing `GITHUB_` or `CI`
- [ ] Default `github.workflow` used in a concurrency group (rename-fragile)
- [ ] No `actionlint`/`zizmor` on the workflows themselves; no `CODEOWNERS`
      on `.github/workflows/`

## Gotchas

- Report-only: do not "helpfully" rewrite workflows during validate.
- `zizmor` findings are often informational; separate genuine errors from
  hardening suggestions.
- A passing `actionlint` does not mean secure (e.g. broad permissions pass).
- Dependabot alerts do not fire for SHA-pinned actions, so pinning is not a
  substitute for pin-update automation.
- Auditing an own shared action library is a different lifecycle
  (`kerpo-gha-action-library`).
