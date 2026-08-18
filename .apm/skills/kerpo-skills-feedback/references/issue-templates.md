# Issue Templates

Use these templates verbatim. Fill in `{{ }}` placeholders. Remove empty optional sections.

---

## Bug Report (`label: bug`)

```markdown
## Skill

`{{ skill-name }}`

## What I was trying to do

{{ one sentence: what the user asked the agent to do }}

## Expected behavior

{{ what should have happened }}

## Actual behavior

{{ what happened instead }}

## Project context

- Project type: {{ e.g. Next.js app, Python CLI, kerpo-skills repo itself }}
- Trigger prompt (approximate): "{{ the message that should have activated the skill }}"

## Additional context

{{ optional: error messages, screenshots, workarounds tried }}
```

---

## Feature Request (`label: feature-request`)

```markdown
## Skill

`{{ skill-name }}` — or "New skill" if this is a request for a new skill

## Problem / need

{{ what situation prompted this request — what can't the user do today }}

## Proposed solution

{{ what the skill or feature should do }}

## Use cases

- {{ use case 1 }}
- {{ use case 2 }}

## Additional context

{{ optional: similar tools, links, prior art }}
```

---

## Feedback (`label: feedback`)

```markdown
## Skill

`{{ skill-name }}` — or "General" for package-level feedback

## What works well

{{ specific things that are good }}

## What could be improved

{{ specific things that are confusing, slow, missing, or wrong }}

## Suggestions

{{ optional: concrete improvement ideas }}

## Additional context

{{ optional }}
```
