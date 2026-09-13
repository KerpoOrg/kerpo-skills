---
name: kerpo-gha-action-library
description: >-
  Use when building, versioning, testing, releasing, or deprecating the org's
  own library of GitHub Actions and reusable workflows. Apply when the user
  says "create a shared action", "version our actions", "set up the release
  pipeline for shared workflows", "publish a reusable workflow", "deprecate
  this action". Covers distribution topology (marketplace vs central org repo
  vs monorepo), semver tags + floating major, release-please wiring, the
  own-action test stack, and compatibility/deprecation policy. Does not
  activate for consuming workflows in a single repo
  (kerpo-gha-workflow-create/refactor) or auditing third-party workflows
  (kerpo-gha-workflow-validate).
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-gha-action-library

Own the lifecycle of shared actions and reusable workflows: where they live,
how they are versioned, how they are tested before tagging, and how they are
deprecated.

## When to use

- "Create our first shared composite action."
- "Set up versioning and release automation for our reusable workflows."
- "How do we test a `workflow_call` across repos before tagging v1?"
- "Publish a reusable workflow" / "version our actions".
- "We need to deprecate v1 of org/shared-build and give consumers a migration
  path."
- Negative: "add CI to my repo" -> create; "are our actions secure" ->
  validate.

## Instructions

1. Read [references/gha-action-library.md](references/gha-action-library.md)
   for the full lifecycle.
2. Choose distribution topology with
   [references/gha-scale-ladder.md](references/gha-scale-ladder.md): one repo
   per action for clean semver, a central `org/shared-workflows` repo for the
   private standard, or a monorepo when the actions ship together.
3. Define the public contract first:
   - Composite action: `action.yml` inputs/outputs (kebab-case), `shell:` on
     every `run:` step, mandatory `description:`.
   - Reusable workflow: `on.workflow_call.{inputs,secrets,outputs}`;
     kebab-case inputs/outputs, UPPER_SNAKE secrets. Adding an optional input
     is patch/minor; removing or retyping is a major.
4. Wire release automation (release-please or semantic-release) producing
   `vX.Y.Z` tags plus a force-pushed floating major `vN`. Remember
   `GITHUB_TOKEN`-created tags do not retrigger workflows; chain via
   `workflow_call` or a PAT when a downstream release must run.
5. Test before tagging:
   - Static: `actionlint`, `zizmor`, `shellcheck`, `mpdude/action-validator`.
   - Docs: `npalm/action-docs --update-readme` with a fail-on-diff check.
   - Composite/JS: consumer workflow in the same repo (`uses: ./`) plus
     `check-dist` for bundled `dist/`.
   - Reusable: `act` is smoke-only; the real contract test is a consumer repo
     calling `@main`/`@feature-branch` before tagging.
6. Document compatibility and a deprecation policy; find consumers via the
   Dependents graph, org code search, and the audit-log API.
7. Apply names per
   [references/gha-naming-conventions.md](references/gha-naming-conventions.md).

## References

- [references/gha-action-library.md](references/gha-action-library.md)
- [references/gha-scale-ladder.md](references/gha-scale-ladder.md)
- [references/gha-naming-conventions.md](references/gha-naming-conventions.md)

## Gotchas

- `GITHUB_TOKEN`-created tags do not trigger other workflows; a downstream
  release needs a PAT or a `workflow_call` chain.
- Marketplace publishing requires a public repo with a single root
  `action.yml`; monorepo sub-actions cannot be marketplace entries.
- Environment secrets cannot pass through a reusable workflow; document that
  for callers.
- Reusable workflow nesting is capped at 10.
- Keep reusable refs on floating tags for consumers, but SHA-pin third-party
  actions inside the library.
- Dependabot does not alert on SHA-pinned actions; track drift yourself.
- `secrets: inherit` only for same-org/enterprise callers.
- This skill owns the library lifecycle, not single-repo CI
  (`kerpo-gha-workflow-create/refactor`).
