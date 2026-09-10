---
name: kerpo-skill-eval
description: >-
  Use when the user asks to run output-quality evals, run-evals, or a with_skill
  vs without_skill iteration for a kerpo skill. Apply to drive a full iteration:
  load evals.json, run each case both ways, grade, then write benchmark.json.
  Does not activate for trigger-accuracy testing (eval_queries.json /
  test-triggers), converting a script into a skill, or creating a new skill
  scaffold. Sub-steps belong to kerpo-skill-eval-run, kerpo-skill-eval-grade, and
  kerpo-skill-eval-benchmark.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skill-eval

Orchestrate one output-quality eval iteration for a kerpo skill.

**Chain:** for each case → [kerpo-skill-eval-run](../kerpo-skill-eval-run/SKILL.md) → [kerpo-skill-eval-grade](../kerpo-skill-eval-grade/SKILL.md) (both modes). After all cases → [kerpo-skill-eval-benchmark](../kerpo-skill-eval-benchmark/SKILL.md).

If you need the workspace layout, read [references/eval-workspace.md](references/eval-workspace.md).

## Instructions

1. Resolve `kerpo-<name>` and iteration `N` (default 1). Source skill: `.apm/skills/kerpo-<name>/`.
2. Read `.apm/skills/kerpo-<name>/evals/evals.json`. Cases are in `.evals` (object with an array — not a top-level array).
3. Require the Claude CLI for comparable timing. If it is missing, stop and say so.
4. Create `kerpo-<name>-workspace/iteration-<N>/`.
5. For each eval case, in order:
   - Slug the prompt (lowercase, non-alphanumerics → `-`, max 40 chars, strip trailing `-`) into `eval-<slug>/`.
   - Run kerpo-skill-eval-run (with_skill, then without_skill).
   - Run kerpo-skill-eval-grade for with_skill, then without_skill.
6. Run kerpo-skill-eval-benchmark.
7. Tell the user to review `outputs/response.txt`, add assertions if they were empty, then run iteration `N+1`.

## Iteration loop

1. Run this iteration and read timing + grades.
2. Add assertions only after seeing real outputs.
3. Change the skill under test, then run the next iteration.
4. Stop when `delta.pass_rate` stops improving.

## Gotchas

- Not trigger testing — that is `evals/eval_queries.json` / `test-triggers.sh`.
- Do not `jq length` the evals.json root; that counts keys, not cases.
- Do not commit `*-workspace/`.
- Keep both passes on the Claude CLI so the baseline stays comparable.
