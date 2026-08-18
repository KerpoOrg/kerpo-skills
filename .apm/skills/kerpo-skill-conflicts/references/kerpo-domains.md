# Kerpo domains and known competitors

Hint table only. The live kerpo set always comes from the session inventory.
This file does not have to list every kerpo skill or every third-party skill.

Use it after inventorying to spot likely competitors and default resolutions.
If a session kerpo skill is missing here, still compare against it.

## Current kerpo domains

| Domain | Kerpo skills | Job |
|---|---|---|
| TDD / new tests | `kerpo-tdd` | Red-green-refactor; tests through public seams; do not mock internals |
| Test audit | `kerpo-unit-review` | Audit existing tests for anti-patterns |
| Coverage candidates | `kerpo-unit-find-untested-candidates` | Rank 1–3 untested public units; do not write tests |
| Git checkout | `kerpo-git-context` | Resolve repo/worktree when checkout is ambiguous |
| Git dirty state | `kerpo-git-status` | Uncommitted / untracked files for the resolved checkout |
| GH assign | `kerpo-gh-issue-assign` | Assign an issue |
| GH start work | `kerpo-gh-issue-start-work` | Claim issue before work (assign + in-progress) |
| GH closeout | `kerpo-gh-issue-done` | Formal closeout checks, then close; PR merge is not a gate |
| Skill from script | `kerpo-skill-from-script` | Convert a script into APM skills in the kerpo-skills repo |
| Skill evals | `kerpo-skill-eval`, `-run`, `-grade`, `-benchmark` | with_skill vs without_skill output-quality iteration |
| Kerpo feedback | `kerpo-skills-feedback` | File a structured issue on KerpoOrg/kerpo-skills |
| Conflict check | `kerpo-skill-conflicts` | This skill — skip it on both sides of the comparison |
| Template | `kerpo-example` | Scaffold only; not a real domain competitor |

## Known competitors

Default: prefer kerpo. Do not auto-disable.

| Other skill | Typical kerpo match | Likely severity | Default resolution |
|---|---|---|---|
| Third-party TDD / “write tests with mocks” / superpowers-style TDD | `kerpo-tdd` | **clash** if it mocks internals or skips red-green; else **domain** | User/project: disable the other. Built-in: rule to follow `kerpo-tdd` |
| Generic “write unit tests” (no TDD, no audit) | `kerpo-tdd` | **domain** if it writes tests for new work; **none** if it only generates a test file the user asked for without TDD | Prefer `kerpo-tdd` for new work; keep if the other skill is clearly “dump tests, no loop” and the user wants that |
| Bugbot / `review-bugbot` | `kerpo-unit-review` | **domain** (partial) | Keep + boundary: Bugbot = PR/code review bot; kerpo-unit-review = test-suite anti-pattern audit |
| `review-security` | — | **none** | Keep |
| Cursor `create-skill` | `kerpo-skill-from-script` | **trigger** / partial **domain** | Keep + boundary: `create-skill` = general Cursor skill authoring; `kerpo-skill-from-script` = convert a script into APM skills in this repo |
| `create-rule` | — | **none** | Keep |
| `find-skills` | — | **none** | Keep |
| Generic git status / dirty-file helpers | `kerpo-git-status` | **domain** | Prefer kerpo (worktrees / multi-repo). Disable the other if it ignores checkout context |
| Generic “which repo / worktree” helpers | `kerpo-git-context` | **domain** | Prefer kerpo |
| Generic GitHub issue close / “mark done” | `kerpo-gh-issue-done` | **domain** or **clash** if it closes without format/as-built checks | Prefer kerpo closeout |
| Generic “assign issue” / “start this issue” | `kerpo-gh-issue-assign`, `kerpo-gh-issue-start-work` | **domain** | Prefer kerpo |
| Generic “create a GitHub issue” | `kerpo-skills-feedback` | **none** unless it is specifically kerpo-skills feedback | Keep; kerpo-skills-feedback is package feedback only |
| Vercel / web-design / optimize / React best-practices | — | **none** | Keep |
| Cursor `create-hook`, `automate`, `canvas`, `split-to-prs`, `statusline`, SDK, origin, new-repo, share | — | **none** | Keep |

## Kind of other skill

| Path prefix | Kind |
|---|---|
| `~/.cursor/skills-cursor/` | Cursor built-in — cannot uninstall; use a rule |
| `~/.cursor/skills/`, `~/.agents/skills/` | User install — disable, remove, or `disable-model-invocation: true` |
| Workspace `.agents/skills/`, `.cursor/skills/`, `.claude/skills/` | Project install — same as user install |
