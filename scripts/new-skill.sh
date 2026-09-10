#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="${1:-}"

if [[ -z "$SKILL_NAME" ]]; then
  echo "Usage: $0 kerpo-<name>" >&2
  exit 1
fi

if [[ ! "$SKILL_NAME" =~ ^kerpo-[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Error: skill name must match 'kerpo-<lowercase-alphanumeric-with-hyphens>'" >&2
  exit 1
fi

SKILL_DIR=".apm/skills/$SKILL_NAME"

if [[ -d "$SKILL_DIR" ]]; then
  echo "Error: $SKILL_DIR already exists" >&2
  exit 1
fi

mkdir -p "$SKILL_DIR/evals"

cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: >-
  Use when the user... Apply when... Describe what this skill does and when
  to activate it. Include keywords users might say. Max 1024 characters.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# $SKILL_NAME

Brief description of what this skill does.

## When to use

- Situation A
- Situation B

## Instructions

Step-by-step guidance here.

## Gotchas

- Non-obvious facts the agent wouldn't know without this skill
- Edge cases that cause mistakes without explicit guidance
EOF

cat > "$SKILL_DIR/evals/evals.json" << EOF
{
  "skill_name": "$SKILL_NAME",
  "evals": [
    {
      "id": 1,
      "prompt": "Realistic user message that should activate this skill.",
      "expected_output": "Human-readable description of what success looks like.",
      "assertions": []
    },
    {
      "id": 2,
      "prompt": "Another realistic prompt with different phrasing.",
      "expected_output": "Description of expected output.",
      "assertions": []
    }
  ]
}
EOF

cat > "$SKILL_DIR/evals/eval_queries.json" << EOF
[
  {"query": "Message that should trigger this skill", "should_trigger": true},
  {"query": "Message with same keywords but different intent — should NOT trigger", "should_trigger": false}
]
EOF

echo "Created $SKILL_DIR"
echo ""
echo "Next steps:"
echo "  1. Edit $SKILL_DIR/SKILL.md — write instructions and gotchas"
echo "  2. Add ~20 queries to $SKILL_DIR/evals/eval_queries.json (50% should-trigger, 50% should-not)"
echo "  3. Audit all skills: mise run skills -- audit"
echo "  4. Test triggers:  ./scripts/test-triggers.sh $SKILL_NAME"
echo "  5. Add test cases: $SKILL_DIR/evals/evals.json"
echo "  6. Run evals:      ./scripts/run-evals.sh $SKILL_NAME 1"
echo "  7. Deploy local:   mise run skills -- install"
