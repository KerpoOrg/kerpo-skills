# GitHub Actions scale ladder

Always start at the lowest rung that solves the current problem. Escalate only
on a named pain signal. The classic mistake is starting at rung 3 or 4 "for
later" and paying coordination cost from day one.

| Rung | Shape | Where | Graduate when |
|------|-------|-------|---------------|
| 1 | Inline steps in one `ci.yml` | `.github/workflows/` | 3+ jobs duplicate the same setup |
| 2 | Local composite action | `.github/actions/<name>/action.yml` | 3+ workflows duplicate setup, or a second repo needs it |
| 3 | Reusable `workflow_call` in a central repo | `org/shared-workflows` | Cross-repo fan-out/fan-in events are needed |
| 4 | Orchestrator repo with `repository_dispatch` | central orchestrator repo | DAG exceeds ~3 sequential cross-repo hops, or retries/state are needed |
| 5 | External orchestrator | Argo Workflows / Temporal / Dagger | Workflow engine limits are the bottleneck, not the app |

## Rung 1 - inline steps

One `ci.yml` with lint/test/build/deploy jobs. Correct default for a single
repo with a handful of jobs. Keep steps readable; do not extract for its own
sake.

## Rung 2 - local composite action

Move repeated *sequences of steps* into `.github/actions/<name>/action.yml`.

- Composite actions require `shell:` on every `run:` step.
- Directory name and `name:` are kebab-case; `description:` is mandatory.
- Inputs/outputs are kebab-case.
- Test via a consumer workflow in the same repo (`uses: ./`).

## Rung 3 - reusable workflow

Move repeated *jobs* into a `workflow_call` workflow in a central repository.

- Called with `uses: org/shared-workflows/.github/workflows/build.yml@v1`.
- Narrow `with:` inputs; declare `secrets:` explicitly (not `secrets:
  inherit` unless same-org and justified).
- Version with semver tags plus a floating major (`v1`). Never call `@main`.
- The contract is `on.workflow_call.{inputs,secrets,outputs}`; adding an
  optional input is a patch/minor, removing or retyping is a major.
- Remember: a called workflow's permissions run in the **caller's** context.

## Rung 4 - orchestrator repo

Fan-out/fan-in across repositories with `repository_dispatch` and a GitHub App
token, plus a trace-id callback for fan-in. See
[gha-multirepo-orchestration.md](gha-multirepo-orchestration.md). The
orchestrator owns the DAG; satellites keep thin triggers.

## Rung 5 - external orchestrator

When cross-repo retries, timers, or state make ~200 lines of polling glue, move
the DAG to Argo Workflows, Temporal, or Dagger and keep GitHub Actions as
thin runners/triggers.

## Deciding

- Prefer the smallest rung that fits today.
- Escalation is explicit, triggered by a pain signal, not by anticipation.
- On each escalation, delete the duplicated predecessor rather than stacking
  both shapes.
