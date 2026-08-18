---
name: kerpo-skill-eval-grade
description: >-
  Use when grading one kerpo-skill-eval response against assertions from evals.json.
  Apply after with_skill or without_skill output exists and you need grading.json.
  Does not activate for running the eval prompt, aggregating benchmark.json, or
  trigger-accuracy testing.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skill-eval-grade

Judge one eval response against its assertions and write `grading.json`.

## Instructions

1. Read `outputs/response.txt` for the mode (`with_skill` or `without_skill`) under the eval folder.
2. If the file is missing, write empty `assertion_results` and summary zeros, then stop.
3. If `assertions` is empty, write `pass_rate: null` and a note to add assertions after reviewing outputs. Do not invent assertions. Do not treat this as 0%.
4. Otherwise, for each assertion, PASS or FAIL with evidence quoted from the actual response — not from `expected_output` alone.
5. Write `grading.json`: `assertion_results[]` (`text`, `passed`, `evidence`) and `summary` (`passed`, `failed`, `total`, `pass_rate` = passed/total).
6. Print `passed/total` for that mode.

Grade one mode per invocation.

## Gotchas

- `expected_output` is a hint, not a scored assertion.
- Empty assertions must stay `pass_rate: null` so benchmark means stay honest.
- Do not re-run the eval prompt while grading.
