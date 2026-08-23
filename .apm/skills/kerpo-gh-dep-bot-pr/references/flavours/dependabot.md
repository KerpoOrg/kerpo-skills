# Flavour: Dependabot (v1 — stub)

## Status

**Not fully implemented.** Detection is documented so the skill can recognize
Dependabot PRs and fail closed cleanly. Do not claim `merge_ok` for
Dependabot in v1.

## detect(pr)

Strong signals:

- Author `dependabot[bot]` / `app/dependabot`
- Head branch starts with `dependabot/`

## parse(pr)

If detected:

- Set `flavour: dependabot`
- Best-effort parse title/body for package names and versions
- Set `confidence: low`
- Tell the user: Dependabot flavour is a stub; treat as **review** until a
  full adapter exists (metadata parity with `dependabot/fetch-metadata` fields
  such as `update-type`, `dependency-names`, `dependency-type`)

## changelogHints(pr)

Return release links from the Dependabot PR body when present; still do not
auto-recommend merge in v1.
