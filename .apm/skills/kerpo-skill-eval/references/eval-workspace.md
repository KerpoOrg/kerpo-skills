# Eval iteration workspace

```
kerpo-<name>-workspace/iteration-<N>/
├── eval-<slug>/
│   ├── with_skill/
│   │   ├── outputs/response.txt
│   │   ├── timing.json
│   │   └── grading.json
│   └── without_skill/
│       ├── outputs/response.txt
│       ├── timing.json
│       └── grading.json
└── benchmark.json
```

`eval-<slug>`: prompt lowercased, non-alphanumerics → hyphens, max 40 chars, trailing hyphens stripped.

Gitignored: `*-workspace/`. Never commit.

## evals.json

```json
{
  "skill_name": "kerpo-<name>",
  "evals": [
    {
      "id": 1,
      "prompt": "User message that should activate the skill.",
      "expected_output": "What success looks like.",
      "assertions": ["Observable claim about the output"]
    }
  ]
}
```

Read `.evals`. A top-level array is a legacy fallback. Leave `assertions` empty on the first iteration.

## timing.json

```json
{ "total_tokens": 0, "duration_ms": 0 }
```

## grading.json

```json
{
  "assertion_results": [
    { "text": "assertion text", "passed": true, "evidence": "quote or observation" }
  ],
  "summary": { "passed": 1, "failed": 0, "total": 1, "pass_rate": 1.0 }
}
```

Empty assertions: `pass_rate` is `null` plus a note. Never store `0` for “not yet defined”.

## benchmark.json

```json
{
  "run_summary": {
    "with_skill": { "pass_rate": { "mean": 0.0 }, "tokens": { "mean": 0 } },
    "without_skill": { "pass_rate": { "mean": 0.0 }, "tokens": { "mean": 0 } },
    "delta": { "pass_rate": 0.0, "tokens": 0 }
  }
}
```

Skip `null` pass rates when averaging.
