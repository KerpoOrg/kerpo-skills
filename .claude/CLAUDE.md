# kerpo-skills

Public APM skill package for Claude Code, Cursor, and OpenCode. All skills use the `kerpo-` prefix.

## Repo structure

```
.apm/skills/kerpo-<name>/
├── SKILL.md                    # required
├── references/                 # long content (loaded by reference)
├── scripts/                    # executable code
├── assets/                     # templates, resources
└── evals/
    ├── evals.json              # output quality test cases
    └── eval_queries.json       # trigger testing queries
```

## Creating a new skill

```bash
./scripts/new-skill.sh kerpo-<name>
```

This creates the correct directory structure and a SKILL.md skeleton.

## SKILL.md frontmatter

```yaml
---
name: kerpo-<name>
description: >-
  Use when the user... Apply when... (max 1024 characters)
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
```

**Description writing guidelines:**
- Start with "Use when" or "Apply when"
- Intent first, technical details last
- Explicitly mention near-miss cases that should NOT trigger
- Test trigger accuracy before deploying

**Progressive disclosure — keep SKILL.md lean:**
- Agents load `name` + `description` always (~100 tokens)
- `SKILL.md` body is loaded only when activated (<5000 tokens)
- `references/`, `scripts/`, `assets/` are loaded only when needed → reference them explicitly

## Testing

### 1. Structural validity
```bash
mise run skills -- audit          # all skills, fast (no evals)
apm pack --dry-run
```

### 2. Trigger testing (description)
```bash
./scripts/test-triggers.sh kerpo-<name>   # free OpenCode model
# Add ~20 queries to evals/eval_queries.json: 50% should-trigger, 50% should-not
# Should-not cases: near-misses (same topic, different intent)
```

### 3. Output quality evals
```bash
./scripts/run-evals.sh kerpo-<name> 1   # free OpenCode model
# Runs evals/evals.json test cases with_skill and without_skill baseline
# Results: kerpo-<name>-workspace/iteration-1/
```

Evals use free OpenCode Zen models (`mise` pins `opencode`; run
`opencode auth login` once). See [docs/evals.md](../docs/evals.md).

**Iteration loop:**
1. Run evals → inspect results and timing (tokens, time)
2. Add assertions to `evals.json` only after seeing the first outputs
3. Give eval signals + SKILL.md to the agent → ask for improvement suggestions
4. Run a new iteration → compare benchmark.json delta
5. Stop when improvement plateaus

## Deploy

```bash
apm pack                              # creates build/kerpo-skills-x.y.z/
apm install build/kerpo-skills-x.y.z # deploys to this project (project scope)
mise run skills -- install --global  # deploys to user scope (~/.claude, ~/.agents, ~/.config/opencode)
```

Targets: `claude`, `cursor`, `opencode` (declared in `apm.yml`). Cursor and
OpenCode read `.agents/skills/` (converged path); Claude reads
`.claude/skills/`; at user scope OpenCode reads `~/.config/opencode/skills/`.  
`apm install` without an argument installs only external `dependencies.apm`
dependencies.

Commit: `apm.yml`, `apm.lock.yaml`, `.apm/`  
Gitignore: `apm_modules/`, `*-workspace/`, `build/`

## Skills interacting with each other

- **Shared content:** `.apm/references/` → reference with `LOAD references/shared.md`
- **Package deps:** `apm.yml` → `dependencies.apm: [kerpo/other@v1.0.0]`
- **Agents:** `.apm/agents/` can orchestrate multiple skills

<!-- kerpo-gh-content-policy-learn:start -->
## GitHub content policy

Full policy: `.github/content-policy.md` (learned 2026-08-19, re-confirmed
2026-08-23). No human-authored PR exists yet in this repo — issue bodies use
`## Skill` / `## Problem / need` / `## Proposed solution` (Do / Do not) /
`## Use cases` / `## Additional context`; no checkboxes. PR body conventions
are proposed defaults only until real PR history exists — mirror the issue
heading style rather than inventing new sections, and prefer `Closes #N` for
issue links.
<!-- kerpo-gh-content-policy-learn:end -->
