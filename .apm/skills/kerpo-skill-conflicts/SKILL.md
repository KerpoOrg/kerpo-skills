---
name: kerpo-skill-conflicts
description: >-
  Use when the user wants to check other installed skills in the running session
  for conflicts with the kerpo- skillset. Apply when the user says "check skill
  conflicts", "are my skills fighting kerpo", "onko skillit ristiriidassa",
  "overlapping skills", or asks what to do about skills that clash with kerpo.
  Inventories session skills, classifies trigger/domain/instruction conflicts,
  and suggests how to resolve them. Does not activate for creating a new skill,
  converting a script into a skill, reporting a kerpo bug, running evals, or
  listing skills with no conflict-check intent.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skill-conflicts

On-demand check: other skills in this session vs the loaded kerpo- set. Report
conflicts and tell the user what to do. Do not disable or edit anything unless
the user asks.

For known kerpo domains and competitor playbooks, read
[references/kerpo-domains.md](references/kerpo-domains.md) after inventorying.

## Instructions

### Step 1 — Inventory the session

Use the running session’s skill list (Cursor `available_skills`, Claude Code
equivalent). Each entry already has `name`, `description`, and `fullPath`.

1. Partition into `kerpo-*` vs other.
2. Skip `kerpo-skill-conflicts` on both sides.
3. If no kerpo skills are loaded, say so and stop.

Do not crawl the filesystem when the session list is present.

**Fallback** (session list missing): glob `SKILL.md` under workspace
`.agents/skills/`, `.cursor/skills/`, `.claude/skills/`, plus
`~/.cursor/skills/` and `~/.agents/skills/`. Skip `~/.cursor/skills-cursor/`
unless those skills already appeared in the session list.

Compare only against kerpo skills loaded in this session — not kerpo skills
that exist on disk but are not loaded.

### Step 2 — Classify each other skill

Compare descriptions first. For suspected overlaps only, read that skill’s
`SKILL.md` and the matching kerpo `SKILL.md` to confirm instruction clash.
Do not read every skill body.

Assign the highest matching severity:

| Severity | Meaning |
|---|---|
| **clash** | The other skill tells the agent to do the opposite of kerpo |
| **domain** | Same job (TDD, git dirty-state, GitHub issue closeout, …) even if wording differs |
| **trigger** | Descriptions would fire on the same user phrasing, jobs still distinct |
| **none** | Complementary — no kerpo counterpart, or a clear near-miss |

Severity order: clash > domain > trigger. One row per other skill; if several
kerpo skills match, name the closest one.

Do not invent conflicts. Complementary skills (Vercel perf, find-skills,
create-rule with no kerpo counterpart) are **none**.

Kerpo vs kerpo is out of scope as a foreign conflict. Only mention it if two
loaded kerpo descriptions would fire on the same phrasing with no near-miss
carve-out.

### Step 3 — Suggest resolution (prefer kerpo)

Do not auto-disable. Default: prefer kerpo.

| Other skill kind | Clash / full domain overlap | Partial overlap (clear near-miss) |
|---|---|---|
| User/project install (`~/.cursor/skills`, `~/.agents/skills`, `.agents/skills`, `.cursor/skills`) | Disable or remove the other skill, or set `disable-model-invocation: true` | Keep both; tighten the other description / document the boundary |
| Cursor built-in (`~/.cursor/skills-cursor/`) | Cannot uninstall — add a project/user rule: when both apply, follow the kerpo skill | Keep; note the boundary in the report |

### Step 4 — Report

If there are no conflicts, say so in one sentence. Otherwise:

```markdown
# Skill conflicts vs kerpo

Kerpo skills in session: N
Other skills checked: M

## Conflicts
- **[clash|domain|trigger]** `other-name` vs `kerpo-…`
  Why: one sentence
  Do this: one concrete action (disable / rule / keep-with-boundary)

## No conflict
- `other-name` — complementary
```

List conflicts before the keep list. Keep the keep list short (name + reason).

## Gotchas

- Session list is the source of truth; a skill on disk but not loaded is not
  in conflict for this check.
- Cursor built-ins cannot be uninstalled. A rule beats pretending they are gone.
- Partial overlap with a documented near-miss is keep-with-boundary, not clash.
- Finnish and English phrasing both count as a user request to run this skill.
