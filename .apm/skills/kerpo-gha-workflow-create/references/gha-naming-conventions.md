# GitHub Actions naming conventions

The de-facto standard, written down. One cross-cutting rule:

- **kebab-case** for YAML identifiers: file names, job ids, step ids, inputs,
  outputs, labels, IAM roles.
- **UPPER_SNAKE** for the environment/secret layer: `env:`, `secrets`, `vars`.
- **Title Case** for human display strings: `name:`, `run-name:`.

## Workflows

- File: `kebab-case.yml`, one workflow per concern, no numeric ordering
  prefixes. Examples: `ci.yml`, `deploy-production.yml`, `release.yml`.
- `name:` is short Title Case, no emoji, no repository context. It is display
  text.
- `run-name:` is for dynamic per-run titles (e.g. include the PR number).
- Warning: `github.workflow` equals `name:`. Renaming the workflow **breaks**
  `workflow_run` triggers and default concurrency groups that referenced the
  old name. Use `github.workflow_id` (stable) in concurrency groups.

## Jobs

- Job id: lower-kebab, stable, describes the unit: `deploy-staging`,
  `integration-tests`.
- `name:`: Title Case, with matrix interpolation:
  `Deploy (${{ matrix.region }})`.

## Steps

- `id:` only when an output is referenced downstream, and keep it minimal:
  `cache`, `get-date`, `version`.
- `name:`: imperative Title Case for non-trivial `run:` steps.
- Skip `name:` on `uses:` steps; the action's own name shows.

## Composite and reusable units

- Composite action directory and `name:` match kebab-case; `description:` is
  mandatory.
- Reusable workflows in a central repo: kebab filenames, `shared-` prefix,
  immutable release tags plus a floating major.
- Reusable inputs/outputs: kebab-case (`node-version`). Reusable secrets:
  UPPER_SNAKE (`NPM_TOKEN`).

## Environments

- lowercase, spelled out, with hyphen qualifiers: `production`,
  `production-eu`, `staging`. `github-pages` is reserved.

## Concurrency

- Groups are repository-scoped and case-insensitive.
- Use fixed semantic names for deploy queues: `production-deploy`.
- Reference `github.workflow_id`, not `github.workflow`, in default groups.

## Secrets, vars, env

- UPPER_SNAKE with a provider or consumer prefix: `AWS_ACCESS_KEY_ID`,
  `SONAR_TOKEN`, `NPM_TOKEN`.
- `GITHUB_` is reserved; do not create variables with that prefix.
- GitHub App credentials: `APP_ID`, `APP_PRIVATE_KEY`.
- `env:` is UPPER_SNAKE at every scope; declare at the narrowest scope that
  works; never shadow the built-in `CI` variable.

## Caches

- Key order: platform -> package manager / lockfile -> hash last, with a
  leading version segment to force invalidation:
  `Linux-node-<hash>` -> better `Linux-node20-<hash>` and a literal `v3-`
  prefix when the cache schema changes.

## Artifacts and matrices

- Artifact names: explicit kebab-case plus a matrix suffix when uploaded per
  matrix entry (`binary-linux`, `binary-macos`).
- Matrix keys: domain-meaningful (`os`, `node-version`); behavior flags read
  as booleans (`experimental: true`).
- Runner labels: lowercase composed capability tokens (`gpu`, `arm64`);
  runner groups kebab-case.

## Cloud identities

- OIDC IAM roles: `github-actions-<repo>-<env>`, mirrored exactly in the trust
  claim conditions so the role and the claim cannot drift.
