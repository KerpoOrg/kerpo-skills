# Building and releasing an action library

For an organization's own composite actions and reusable workflows: where to
publish, how to version, how to test, and how to deprecate.

## Distribution topology

- **GitHub Marketplace**: public repo, a single `action.yml` at the repository
  root, a unique `name`, published via the release checkbox.
- **Central org repo** (`org/shared-workflows`, `org/actions`): the private
  standard. Version by tags. Enable the org-level "accessible from
  repositories in the organization" setting; consumers then get a scoped,
  1-hour read token.
- **Monorepo of actions**: one shared tag, or subdirectory-prefixed tags.
  Marketplace publishing is limited to a root `action.yml`, so monorepo
  actions generally cannot be marketplace entries.
- **One repo per action** gives the cleanest per-action semver and is GitHub's
  own recommendation.

## Versioning

- Tag every release `v1.2.3`.
- Maintain a floating major `v1` that points at the latest patch of that
  major:

  ```bash
  git tag -fa v1 -m "v1 latest"
  git push --force origin v1
  ```

- On a name collision a tag beats a branch.
- Bump majors for input or behavior incompatibilities. Keep the old major
  alive on a `releases/v1` branch.
- Use `v2-beta` / a canary tag before stabilizing a new major.
- Consumers: SHA with a `# v1.2.3` comment (Renovate understands and updates
  it). A full-SHA enforcement policy is available (Aug 2025+).
- New `$/` self-repo syntax (GA Jul 2026) composes same-repo actions and
  workflows at the running commit.

## Release automation

- `googleapis/release-please-action@v4`: conventional commits -> Release PR ->
  tag + GitHub Release. Add a step that force-pushes the floating `vN`.
- Or `semantic-release` with the `semantic-release-major-tag` plugin.
- `softprops/action-gh-release` for manual asset releases.
- Warning: tags created by `GITHUB_TOKEN` do **not** retrigger workflows. If a
  downstream release pipeline must run, use a PAT or chain via
  `workflow_call`.
- Experimental - do not ship yet: `actions/publish-immutable-action` (OCI
  artifacts to ghcr.io with provenance), `github/gh-actions-lock` (Technical
  Preview, pins all `uses:` to verified commits; Renovate integration
  experimental), Immutable Releases.

## Testing your own actions

- Static: `actionlint`, `zizmor`, `shellcheck`, and
  `mpdude/action-validator`.
- Docs freshness: `npalm/action-docs` with `--update-readme`, failing the job
  on a diff so the README cannot drift.
- Composite actions: a consumer workflow in the same repo (`uses: ./`) with an
  input matrix and output assertions, run on every PR.
- JS/TS actions: commit a rollup-bundled `dist/` and add a `check-dist` job
  (`rebuild && git diff --exit-code`); unit test with `@actions/core` mocked;
  debug locally with `@github/local-action`.
- Reusable workflows: `act` (nektos) resolves `workflow_call` but skips OIDC,
  environments, permissions, and concurrency, so it is smoke-only. The real
  contract test is a dedicated consumer repo calling `@main` /
  `@feature-branch` before tagging; that catches access-policy and permission
  bugs. Fan out a matrix over input/event combinations.

## Reusable workflow contract

- Defined by `on.workflow_call.{inputs,secrets,outputs}`.
- Adding an optional input is a patch/minor; removing or retyping is a major.
- Document every contract change in `CHANGELOG`.
- `secrets: inherit` only for same-org/enterprise callers.
- Environment secrets cannot pass through a reusable workflow.
- Maximum nesting depth is 10.
- Keep reusable workflow refs on floating tags (Renovate `matchDepTypes` for
  workflows); SHA-pin third-party actions.

## Deprecation

- Find consumers via the Dependents graph, org code search for
  `uses: org/my-action@`, and the audit-log API.
- Dependabot alerts do **not** fire for SHA-pinned actions, so pinning hides
  version drift from security tooling.
- When a bad release ships, use the org action blocklist as a kill switch.
