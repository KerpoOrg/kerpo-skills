---
name: kerpo-gha-workflow-refactor
description: >-
  Use when improving existing GitHub Actions pipelines: slow or flaky CI,
  duplicated builds for the same commit, missing artifact reuse, wasteful
  Docker/DinD builds, draft vs ready-for-review depth, duplicated setup or
  jobs, migration to OIDC / SHA pinning, extracting composite actions or
  reusable workflows, merge-queue enablement. Apply when the user says "CI is
  slow", "speed up the pipeline", "optimize our workflows", "build once and
  reuse", "we rebuild the same image every job", "stop using docker-in-docker",
  "make draft PRs faster", "deduplicate our workflows", "extract a reusable
  workflow", "reduce Actions minutes". Graduates the scale ladder on pain
  signals and applies the perf playbook (build once per SHA, build only what
  changed, progressive PR depth, target-branch confidence, no DinD, late
  container fan-out). Does not activate for creating new workflows
  (kerpo-gha-workflow-create), report-only audits
  (kerpo-gha-workflow-validate), or lifecycle work on an own action library
  (kerpo-gha-action-library).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.1"
---
# kerpo-gha-workflow-refactor

Improve existing workflows: make them faster and more reliable, remove
duplication via the scale ladder, and modernize security/triggers. Change
behavior deliberately and verify with real run timings.

## When to use

- "Our CI takes 40 minutes, speed it up." / "optimize the pipeline".
- "We rebuild the same thing in every job for the same commit."
- "Draft PRs are too slow; deepen checks only when ready for review."
- "Stop building inside DinD" / "share one base image across services".
- "We have the same 60-line setup in five workflows, deduplicate it."
- "Migrate our deploy from static AWS keys to OIDC."
- "Pin all third-party actions to SHAs across the org."
- "Enable the merge queue / our merge queue is stuck."
- Negative: "add CI to my repo" -> create; "just audit our workflows" ->
  validate; "version our shared actions" -> action-library.

## Instructions

1. Read the current workflows and get real timings before changing anything.
   Identify the dominant cost (queue time vs run time vs duplicated
   builds/setup). Note the PR merge target (main/integration/other).
2. Apply [references/gha-perf-playbook.md](references/gha-perf-playbook.md)
   end-to-end. Prioritize the five rules before runner upsizing:
   - Collapse duplicate builds for the same SHA into one job + artifacts /
     registry tags reused by later jobs and workflows.
   - Add change detection so unchanged packages are not rebuilt.
   - Split draft/push fast path from ready-for-review / merge-queue depth.
   - Align required checks with the real merge target to cut post-merge churn.
   - Move compilation out of DinD; pull shared bases once and fan out late.
   Also apply concurrency, `timeout-minutes`, lockfile-keyed caches, and
   matrix tuning.
3. Deduplicate with the extraction ladder in
   [references/gha-scale-ladder.md](references/gha-scale-ladder.md):
   - 3+ duplicated **steps** in one repo -> local composite action.
   - 3+ duplicated **jobs** in one repo -> reusable `workflow_call` locally.
   - Multiple repos / central need -> reusable workflow in the org repo.
   - Cross-repo fan-out/fan-in -> orchestrator (see
     [references/gha-multirepo-orchestration.md](references/gha-multirepo-orchestration.md)).
   Delete the duplicated predecessor; do not stack both shapes.
4. Modernize:
   - Migrate static cloud keys to OIDC (`id-token: write`, trust scoped to
     `job_workflow_ref`).
   - Run a pin-to-SHA campaign for third-party actions; keep a version comment
     so pin-update tooling still works.
   - `actions/checkout` v4 -> v5 and `upload-artifact` v4 uniqueness: give
     every upload a unique name (include `${{ github.sha }}` when useful).
   - Add `run-name:` for dynamic per-run titles.
   - Concurrency groups: rebuild them after a rename, since `github.workflow`
     is the display name and no `workflow_id` context property exists.
5. If a merge queue is in use, add `merge_group` to every required workflow.
6. For org-wide rollout of shared workflows: publish semver tags plus a
   floating major, run a canary tag first, migrate callers over a 4-8 week
   window, and never call `@main` from a caller.
7. Follow [references/gha-naming-conventions.md](references/gha-naming-conventions.md)
   for any renamed or new identifiers.
8. Report the before/after timings, which optimization rules were fixed, the
   extractions made, and the migration steps left for the user.

## References

- [references/gha-perf-playbook.md](references/gha-perf-playbook.md)
- [references/gha-scale-ladder.md](references/gha-scale-ladder.md)
- [references/gha-multirepo-orchestration.md](references/gha-multirepo-orchestration.md)
- [references/gha-naming-conventions.md](references/gha-naming-conventions.md)

## Gotchas

- Optimize what is measured. Do not move to larger runners before profiling.
- Caches are read-only on PRs and evicted after 7 days; a cache miss must not
  fail the job. Caches do not replace SHA-keyed artifacts.
- `actions/upload-artifact` v4 is immutable: reusing a name fails. Add a matrix
  or SHA suffix.
- A required workflow without `merge_group` stalls the whole merge queue.
- Extracting too early adds coordination cost. Escalate only on the pain
  signals.
- Do not retry deploys automatically; retry flaky tests only.
- Rebuilding "to keep jobs independent" is usually the wrong trade — share
  artifacts instead.
- This skill changes existing workflows. It does not create new ones
  (`kerpo-gha-workflow-create`) or own a shared library
  (`kerpo-gha-action-library`).
