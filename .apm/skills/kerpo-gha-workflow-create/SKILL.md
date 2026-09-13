---
name: kerpo-gha-workflow-create
description: >-
  Use when creating a new GitHub Actions workflow (lint/test/build/deploy) for
  a repository. Apply when the user says "add CI", "create a workflow", "set up
  GitHub Actions", "add a deploy pipeline", or asks to scaffold a pipeline for
  a project. Picks the minimal architecture tier that fits (inline steps ->
  composite action -> reusable workflow -> org orchestrator), applies the
  kerpo security baseline, and follows the naming conventions. Does not
  activate for refactoring existing workflows (kerpo-gha-workflow-refactor),
  report-only audits (kerpo-gha-workflow-validate), or an own action library
  (kerpo-gha-action-library).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gha-workflow-create

Author new GitHub Actions workflows to kerpo standards: choose the smallest
architecture tier, apply the security baseline from the first line, and name
everything consistently.

## When to use

- "Add CI for this repo: lint, typecheck, test, build."
- "Set up GitHub Actions" / "create a workflow".
- "Add a deploy pipeline" (including OIDC to a cloud, gated by an
  environment).
- "Scaffold a Docker build-and-push pipeline."
- Negative: "CI is slow, fix it" -> refactor; "review my workflows" ->
  validate; "build our own shared action" -> action-library.

## Instructions

1. Detect the stack and the repo shape (root vs monorepo, package manager,
   test command, default branch, whether a merge queue is enabled).
2. Pick the architecture tier with
   [references/gha-scale-ladder.md](references/gha-scale-ladder.md). Start at
   rung 1; escalate only on a named pain signal. Most requests are rung 1.
3. Apply the security baseline from the first line, per
   [references/gha-security-baseline.md](references/gha-security-baseline.md):
   default-deny `permissions`, SHA-pinned third-party actions, OIDC over static
   cloud keys, no untrusted `${{ }}` in `run:`.
4. Name files, jobs, steps, environments, secrets, and cache keys per
   [references/gha-naming-conventions.md](references/gha-naming-conventions.md).
5. Add the performance defaults from
   [references/gha-perf-playbook.md](references/gha-perf-playbook.md): a
   `concurrency` group, `timeout-minutes` on every job, lockfile-keyed caches.
6. Start from a template in [assets/](assets) when one matches the stack
   (Node, Python, Go, Docker build+push, Terraform, OIDC deploy). The
   templates are already SHA-pinned; keep the pins.
7. If the repo uses a merge queue, add `merge_group` to `on:` for every
   workflow that is a required check, or the queue stalls.
8. Do not extract composite actions or reusable workflows until the scale
   ladder says so.
9. Report the files created, the tier chosen and why, and any secrets/OIDC
   setup the user must complete out of band.

## References

- [references/gha-scale-ladder.md](references/gha-scale-ladder.md) - which tier
- [references/gha-security-baseline.md](references/gha-security-baseline.md) - non-negotiables
- [references/gha-naming-conventions.md](references/gha-naming-conventions.md) - names
- [references/gha-perf-playbook.md](references/gha-perf-playbook.md) - speed/cost
- [assets/](assets) - per-stack starter workflows

## Gotchas

- Never start at rung 3+ ("we'll need reusable workflows later"). Coordination
  cost is paid from day one; escalate on pain only.
- Never `@main`/branch refs, and no bare major tags for third-party actions.
- A top-level `permissions:` block is required; repository defaults are often
  read/write-all.
- `github.workflow` is the display `name:`, not a stable id. Renaming a
  workflow breaks `workflow_run` triggers and default concurrency groups.
  Use `github.workflow_id`.
- `merge_group` must be on every required workflow, not just one.
- Do not commit secrets; document required secrets/OIDC trust instead.
- This skill creates workflows. It does not audit (`kerpo-gha-workflow-validate`)
  or own a shared action library (`kerpo-gha-action-library`).
