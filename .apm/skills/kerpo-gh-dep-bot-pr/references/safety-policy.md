# Safety policy

Apply after flavour parse and migration impact classification. **Fail closed.**

## Gates

| Gate | Rule |
|------|------|
| Actor | Known flavour required (`renovate` or stub `dependabot`). Unknown author → stop; not a dep-bot PR. |
| Dependabot stub | Detected Dependabot → decision at best `review`; never `merge_ok` in v1. |
| Draft | Never merge drafts. |
| Conflicts | Do not merge; suggest Renovate recreate / rebase. |
| Checks | For `merge_ok`: required checks must succeed. Pending → `wait_ci`. Failed → leave open (or `fix_on_branch` if failures are from known migration gaps). |
| Changelog missing | Cannot claim `merge_ok` (even if semver is patch). |
| Usage scan failed | If the package appears imported but usage could not be assessed → `review`. |
| Update kind | `major` / `unknown` / `breaking` label → at least `review`; after analysis often `major_migration`. |
| Grouped PRs | Worst package impact and worst updateKind win. |
| High-risk packages | See list below — require deeper analysis; prefer `review` or `fix_on_branch` over blind `merge_ok`. |
| Security | Security + impact `none` + green CI → may recommend `merge_ok` (still confirm). Security + `major` impact → `major_migration`. |
| Branch protection | Merge only via `gh pr merge --auto`. Never `--admin`, never force. |

## High-risk package patterns (default denylist)

Treat as high-risk when the package name matches (case-insensitive substring /
common names):

- Frameworks / runtimes: `react`, `react-dom`, `next`, `vue`, `nuxt`, `angular`,
  `svelte`, `express`, `fastify`, `django`, `rails`, `spring`, `laravel`
- Bundlers / compilers: `webpack`, `vite`, `rollup`, `esbuild`, `swc`,
  `typescript`, `babel`
- Auth / crypto / security: `passport`, `jsonwebtoken`, `jose`, `oauth`,
  `openid`, `bcrypt`, `crypto`, `helmet`
- Infra clients: `aws-sdk`, `@aws-sdk/`, `prisma`, `typeorm`, `sequelize`,
  `mongoose`, `pg`, `mysql`, `redis`, `ioredis`

User may override high-risk caution **in-session** with an explicit instruction;
still never skip changelog/usage analysis for `merge_ok`.

## Autonomy

- Recommend first; **confirm** before approve, merge, push to PR branch, or
  create a migration issue.
- Never silent merge.

## Combining with impact

| Impact | Typical decision |
|--------|------------------|
| `none` + gates pass | `merge_ok` |
| `none` + checks pending | `wait_ci` |
| `small` | `fix_on_branch` |
| `major` | `major_migration` |
| ambiguous / missing data | `review` |
