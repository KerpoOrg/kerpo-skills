---
name: kerpo-skill-from-script
description: >-
  Use when converting an existing script (bash, Python, etc.) into an APM skill.
  Apply when the user says "make this a skill", "convert this script", "turn this
  into a skill", or wants to replace a script with agent-native instructions in
  the kerpo-skills repo. Does not activate for general script debugging, writing
  new scripts, or non-APM skill conversion tasks.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skill-from-script

Converts a script into one or more APM skills in the kerpo-skills repo, replacing
imperative code with agent-native instructions.

## Step 1 — Analyze the script

Read the script and summarize:
- **Purpose:** one sentence describing what it does
- **Inputs:** arguments, files read, env vars
- **Outputs:** files written, stdout, side effects
- **Steps:** numbered list of high-level actions (not code lines)

## Step 2 — Decompose into skills

A complex script almost always becomes multiple skills, not one. Split along natural
boundaries — each skill should be a coherent unit of work (like a well-scoped function).

**Fits in a skill:**
- Decision-making, analysis, interpretation
- Reading and writing files based on judgment
- Producing structured output from unstructured input

**Keep as a script (or Bash tool call):**
- Tight loops over large datasets
- Calling third-party binaries with fixed arguments
- Precise timing-critical operations

**Naming convention — prevent namespace pollution:**

| Type | Pattern | Example |
|---|---|---|
| Standalone feature | `kerpo-<feature>` | `kerpo-eval` |
| Sub-skill | `kerpo-<feature>-<sub>` | `kerpo-eval-run`, `kerpo-eval-grade` |

Rule: ask "is this sub-skill meaningful without its parent?" If no → use parent namespace.
If unsure, ask the user before proposing names.

For each identified skill unit, propose a namespaced name and one-sentence purpose.
Ask the user to confirm the decomposition before proceeding if it's non-obvious.

**Skill chains:** when skills depend on each other, note the chain order.
For orchestration across many skills, consider `.apm/agents/` instead.

## Step 3 — Write SKILL.md for each skill

For each skill, create `.apm/skills/kerpo-<name>/SKILL.md` using this structure:

```markdown
---
name: kerpo-<name>
description: >-
  Use when... Apply when... (max 1024 chars, "Use when" first, intent before conditions)
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-<name>

One-sentence description.

## Instructions

Agent-native steps — not shell commands translated 1:1, but what the agent *does*:
- Read X, look for Y
- Write result to Z in format W
- If condition A, do B; otherwise do C

Move detailed reference material to references/<topic>.md and link explicitly:
"If you need the full schema, read [references/schema.md](references/schema.md)."

## Gotchas

- Non-obvious edge cases from the original script
- Assumptions baked into the original code that the agent must know
```

**Key principle:** translate *intent*, not syntax. `grep -r "TODO" .` → "Search all files for TODO comments."

## Step 4 — Create eval scaffolding

For each skill, create:

```
.apm/skills/kerpo-<name>/evals/evals.json       — 2-3 realistic test prompts
.apm/skills/kerpo-<name>/evals/eval_queries.json — trigger query placeholders
```

Use the templates from kerpo-example as a starting point.

## Step 5 — Validate and deploy

```bash
apm audit --file .apm/skills/kerpo-<name>/SKILL.md
apm install --dry-run
apm install
```

## Gotchas

- Don't translate commands 1:1 — think about what the agent *would do*, not what the code executes
- `apm audit` catches hidden Unicode characters that silently break deployment
- Skill names: `kerpo-` prefix, lowercase, hyphens only — sub-skills use `kerpo-<parent>-<sub>` to prevent namespace pollution
- Description is the only thing the agent sees before deciding to activate the skill — make it count
- If the original script has many flags/options, the skill should handle the common case well and document edge cases in Gotchas, not enumerate every flag
