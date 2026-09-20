---
name: kerpo-gha-workflow-validate
description: >-
  Use when auditing or validating GitHub Actions workflows against the kerpo
  baseline: actionlint + zizmor, permissions review, SHA pinning, template
  injection (${{ }} in run:), timeout-minutes, concurrency, cache hygiene,
  naming conventions, and pipeline optimization (build once per commit SHA,
  build only what changed, progressive draft vs ready-for-review depth,
  target-branch confidence, DinD avoidance, late container fan-out). Apply
  when the user says "audit our workflows", "are our workflows secure",
  "check CI quality", "validate github workflows", "are we rebuilding too
  much", "review pipeline performance practices", "check for docker-in-docker
  builds". Report-only, errors first then warns; suggests composing
  kerpo-gha-workflow-refactor when fixes are wanted. Does not activate for
  creating (kerpo-gha-workflow-create), refactoring
  (kerpo-gha-workflow-refactor), or auditing your own action library
  (kerpo-gha-action-library).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.1"
---
# kerpo-gha-workflow-validate

Audits `.github/workflows/**` and `.github/actions/**` against the kerpo
baseline (security, naming, and optimization). Reports findings; does **not**
edit files. When the user wants fixes, compose `kerpo-gha-workflow-refactor`.

## When to use

- "Audit our workflows against best practices."
- "Are our GitHub Actions secure?"
- "Run actionlint/zizmor over `.github/workflows` and tell me what's broken."
- "Check CI quality" / "validate github workflows".
- "Are we rebuilding the same artifacts every job?" / "review pipeline
  performance practices."
- Negative: "fix the vulnerabilities" / "speed it up" -> refactor (validate
  stays report-only); "add CI" -> create.

## Instructions

1. Resolve the repo root (compose `kerpo-git-context` if ambiguous).
2. Read [references/gha-security-baseline.md](references/gha-security-baseline.md),
   [references/gha-naming-conventions.md](references/gha-naming-conventions.md),
   and [references/gha-perf-playbook.md](references/gha-perf-playbook.md).
3. Run the static tools when available:
   - `actionlint` over the workflow files.
   - `zizmor .` for security analysis.
   - `shellcheck` on any inline `run:` scripts extracted for review (or on the
     repo's scripts), where practical.
   - Optional: `mpdude/action-validator` for schema validation.
4. Walk the checklist below; record each finding with file, line, severity
   (error/warn), and a one-line reason.
5. Report errors first, then warns, then an info summary. Suggest
   `kerpo-gha-workflow-refactor` when errors or optimization warns exist.
   Never edit files silently.

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
- [ ] Missing or unscoped `concurrency` on a PR/build workflow
- [ ] No cache for a lockfile-based install (or cache key not lockfile-based)
- [ ] Same commit SHA rebuilt in multiple jobs/workflows without artifact or
      registry reuse (violates build-once)
- [ ] No path/`affected` gating in a monorepo or multi-package repo where
      most PRs touch a subset (violates build-only-what-changed)
- [ ] No progressive depth: draft/push runs the same heavy suite as
      ready-for-review / merge queue
- [ ] PR checks weaker than the merge-target required set in a way that
      invites post-merge breakage
- [ ] Container build compiles inside DinD / nested Docker instead of on the
      runner or host BuildKit
- [ ] Multiple images sharing a base each pull/rebuild the base independently
      (no shared intermediate / late fan-out)
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
