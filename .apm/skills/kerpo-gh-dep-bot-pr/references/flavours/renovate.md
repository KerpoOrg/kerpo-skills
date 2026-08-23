# Flavour: Renovate (v1 — full)

## detect(pr)

Strong signals (any one is enough):

- Author/login matches Renovate: `renovate[bot]`, `app/renovate`, or login
  containing `renovate` in bot context
- Head branch starts with `renovate/`

Weak corroboration only (never alone):

- Labels such as `dependencies`, `renovate`

## parse(pr)

Build `DepUpdate` with `flavour: renovate`.

Sources (best-effort, prefer structured):

1. **Title** — e.g. `Update lodash to v4.17.21`, `chore(deps): update …`,
   grouped titles like `Update dependency group …`
2. **Body tables** — Renovate “Package” / “Update type” / version columns
3. **Labels** — `security` → `isSecurity: true`; breaking / major-ish labels
   raise `updateKind` toward `major`
4. **Files** — lockfile-only changes may indicate `lockfile` / `pin` / `digest`
5. **Branch name** — often encodes package and version range

Set `isGrouped: true` when the title/body clearly lists multiple packages or
uses a group name.

`updateKind`:

- Infer from Renovate “Update type” / semver of from→to when possible
- If any package in a group is major → treat PR `updateKind` as `major`
- If unclear → `unknown` (fail closed later)

`confidence`: `high` when package names and versions are explicit; else `low`.

## changelogHints(pr)

Prefer extracting from the PR body first:

- “Release notes”, “Changelog”, compare URLs, GitHub Releases links
- Renovate’s embedded release-note excerpts

Return a list of `{ package?, url, snippet? }` for migration analysis.
