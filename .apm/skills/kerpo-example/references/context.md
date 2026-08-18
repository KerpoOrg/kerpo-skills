# Reference material (example)

This file is an example of the `references/` pattern used across kerpo-skills:
content here is only loaded by the agent when `SKILL.md` links to it explicitly
(progressive disclosure). Keep `SKILL.md` itself lean — put longer background,
edge-case explanations, schemas, or rarely-needed detail here instead.

## When to add content here

- Detailed explanations that would bloat `SKILL.md` beyond ~5000 tokens
- Background/context that's only needed for unusual cases
- Schemas, templates, or examples too long to inline in the main body

## When NOT to use this

- Core instructions the agent needs every time the skill activates — those
  belong in `SKILL.md` directly, not behind an extra load.
