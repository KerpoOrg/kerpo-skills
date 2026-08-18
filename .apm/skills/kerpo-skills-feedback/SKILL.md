---
name: kerpo-skills-feedback
description: >-
  Use when the user wants to report a bug, request a feature, or send feedback
  about a skill in the kerpo-skills package. Apply when the user says "this skill
  isn't working", "I found a bug in kerpo-", "I'd like to request a feature for
  kerpo-skills", "can you report this to kerpo-skills", or similar. Creates a
  structured GitHub issue on KerpoOrg/kerpo-skills. Does not activate for general
  GitHub issue creation, fixing code in the current project, or feedback about
  tools unrelated to kerpo-skills.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-skills-feedback

Sends structured feedback, bug reports, and feature requests to the kerpo-skills
GitHub repository as issues, using the correct template for AI-agent processing.

## Instructions

### Step 1 — Determine feedback type

Ask the user (or infer from context) which type applies:
- **bug** — a skill behaves incorrectly or fails to activate when expected
- **feature-request** — a new skill or capability that would be useful
- **feedback** — general observations, usability notes, or improvement ideas

### Step 2 — Collect context

Ask only what is missing. Gather:
- Which skill is affected (e.g. `kerpo-skill-from-script`) — or "new skill" for feature requests
- What the user was trying to do (the trigger / use case)
- What went wrong or what is needed

If the user is in a project that uses kerpo-skills, also note: current project name or type (e.g. "Next.js web app"), if relevant to the bug.

### Step 3 — Draft the issue

Use the template for the feedback type from [references/issue-templates.md](references/issue-templates.md).
Fill in all sections. Show the draft to the user and let them edit before submitting.

### Step 4 — Create the issue

Use the first available GitHub access method:

1. **GitHub MCP** (preferred if a GitHub MCP server is active in this session) — use the MCP create-issue tool with `owner: KerpoOrg`, `repo: kerpo-skills`
2. **gh CLI** — `gh issue create --repo KerpoOrg/kerpo-skills --title "..." --body "..." --label "<type>"`

After creation, show the user the issue URL.

## Gotchas

- Target repo is always `KerpoOrg/kerpo-skills`, never the user's current project repo
- Labels must be exactly: `bug`, `feature-request`, or `feedback` — no variations
- Issue body must use the structured template so that an AI agent can auto-triage it
- If neither MCP nor `gh` is available, give the user a formatted issue body they can paste manually at github.com/KerpoOrg/kerpo-skills/issues/new
