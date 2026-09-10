---
name: kerpo-skill-eval-run
description: >-
  Use when running a single kerpo-skill-eval case: one prompt executed with the skill
  loaded and again without it, writing response.txt and timing.json. Apply as a
  step of kerpo-skill-eval, or when the user wants one with_skill vs without_skill
  baseline. Does not activate for grading assertions, writing benchmark.json,
  trigger-query testing, or running the full eval suite (that is kerpo-skill-eval).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skill-eval-run

Run one eval prompt twice — with the skill and without — and record output plus timing.

## Instructions

1. Confirm `.apm/skills/kerpo-<name>/` and workspace `kerpo-<name>-workspace/iteration-<N>/`. Create the iteration folder if missing.
2. Take one case: `id`, `prompt`, folder `eval-<slug>/`.
3. **with_skill:** send the prompt via Claude CLI (`claude -p`, `--skill-path` the skill dir, `--output-format json`). Write assistant text to `eval-<slug>/with_skill/outputs/response.txt`. Write `{total_tokens, duration_ms}` to `timing.json` (tokens from CLI usage; `0` if unknown).
4. **without_skill:** same prompt, no skill path. Write under `eval-<slug>/without_skill/`.
5. Print one line per mode: tokens and duration.

Do not grade. Do not loop other cases.

## Gotchas

- Comparable timing needs the same runner both times. Cursor chat turns are not a CLI baseline.
- On CLI failure, still write the files (possibly empty response, tokens `0`) so grading can record a miss.
- Swallowing stderr is inherited from `scripts/run-evals.sh` — still surface the failure in the summary line.
