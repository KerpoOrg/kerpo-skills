---
name: kerpo-skill-eval-benchmark
description: >-
  Use when summarizing a finished kerpo-skill-eval iteration into benchmark.json:
  mean pass_rate and tokens for with_skill vs without_skill, plus deltas.
  Apply after all cases in the iteration workspace have grading.json and
  timing.json. Does not activate for running evals, grading a single case, or
  trigger-query testing.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skill-eval-benchmark

Fold one iteration's timing and grading files into `benchmark.json` and interpret the delta.

## Instructions

1. Open `kerpo-<name>-workspace/iteration-<N>/` and find every `eval-*/` directory.
2. For each eval, read with_skill and without_skill `grading.json` and `timing.json`.
3. Means:
   - `pass_rate.mean` — average of numeric pass rates only; skip `null`.
   - `tokens.mean` — average of `total_tokens`.
   - Separate with_skill and without_skill.
4. `delta.pass_rate` = with_skill mean − without_skill mean (positive = skill helped).
5. `delta.tokens` = with_skill mean − without_skill mean (positive = skill cost more tokens).
6. Write `benchmark.json` at the iteration root, print it, and say in one or two sentences whether quality improved and at what token cost.
7. If every pass_rate is null, still write token means; set pass_rate means to `null` and say assertions are not ready.

If you need the JSON shape, read [references/eval-workspace.md](references/eval-workspace.md).

## Gotchas

- Do not coerce missing/`null` pass rates to `0`. That hides “no assertions yet” (`scripts/run-evals.sh` uses `// 0`).
- Incomplete eval folders: skip and mention them; do not abort the summary.
- This skill does not start a new iteration.
