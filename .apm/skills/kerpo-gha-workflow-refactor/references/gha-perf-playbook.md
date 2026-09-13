# GitHub Actions performance playbook

Apply these to speed up CI and control spend. Measure before optimizing; use
timings from real runs, not intuition.

## Concurrency

- PR workflows: cancel superseded runs.

  ```yaml
  concurrency:
    group: ${{ github.workflow_id }}-${{ github.head_ref || github.ref }}
    cancel-in-progress: true
  ```

- Deploy workflows: fixed semantic groups and queue instead of cancel.

  ```yaml
  concurrency:
    group: production-deploy
    cancel-in-progress: false
    queue: max   # up to 100 FIFO; incompatible with cancel-in-progress
  ```

- Use `github.workflow_id`, not `github.workflow` (the latter is the display
  name and changes on rename).

## Timeouts

- Set `timeout-minutes` on **every** job. The default is 360 minutes, so a
  hung job can burn hours.
- Rough guides: ~5 for aggregates/notify jobs, 10-15 for lint/test, longer
  only for genuinely long builds.

## Caching

- Prefer the setup actions' built-in cache: `setup-node`, `setup-python`,
  `setup-go`, `setup-java`, `setup-dotnet`. Key on the lockfile hash and set
  `cache-dependency-path` for monorepos.
- Install deterministically: `npm ci`, `pnpm install --frozen-lockfile`,
  `yarn --immutable`, `bundle install --frozen`.
- Raw `actions/cache` (v4/v5) pattern:

  ```yaml
  key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
  restore-keys: |
    ${{ runner.os }}-node-
  ```

- Add a leading version segment (`v3-`, `v4-`) to force invalidation when the
  cache schema or toolchain changes.
- Limits: 10 GB per repository, entries evicted after 7 days of no access.
- Never cache secrets or credentials.
- Cache writes are restricted to the default branch; PR runs read only.
- On privileged publish jobs set `package-manager-cache: false` so a poisoned
  cache cannot influence a release.

## Artifacts

- `actions/upload-artifact` v4 artifacts are immutable. Give each upload a
  unique name (`binary-${{ matrix.os }}`); re-uploading the same name fails.
- Set explicit `retention-days` to control storage cost.
- Use `merge-multiple: true` when merging artifacts from several jobs.
- Set `compression-level`: 0 for already-compressed binaries, ~6 for text.

## Matrices

- Full matrix on push to main / release; reduced matrix on PRs (e.g. one OS,
  one primary runtime version).
- `fail-fast: true` normally; `false` for compatibility matrices where you
  want the full failure picture.
- Use `max-parallel` to cap concurrent spend.

## Merge queue

- On busy branches, enable the merge queue and add `merge_group` to the `on:`
  triggers of **every** required workflow. A required workflow without
  `merge_group` stalls the queue.

## Split fast from slow

- Lint/typecheck/unit: every PR, fast runner, fail quickly.
- Integration/build/deploy: main and release only, or behind a label.
- `ubuntu-24.04` is the default; use larger runners only after measurement
  shows a real bottleneck that parallelism can fix.

## Path gating

- `dorny/paths-filter@v4`: tool-agnostic change detection. Treat its `_files`
  outputs as untrusted on PRs (they derive from the diff).
- Nx / Turborepo `affected`: graph-aware, cascades shared-library changes.
  Turborepo Remote Cache can authenticate via OIDC.
- Built-in `on.<event>.paths:`: gates the **whole** workflow only; no per-job
  gating.
