# GitHub Actions performance playbook

Optimize pipelines for **speed and reliability**. Measure before optimizing;
use timings from real runs, not intuition.

## Non-negotiable optimization rules

### 1. Build once per commit, then reuse

If something is built for a given commit SHA, build it **once**, store it, and
reuse it in later jobs and workflows. Do not rebuild the same outputs for the
same SHA across jobs, workflows, or matrix legs.

- Prefer a dedicated `build` job that uploads artifacts keyed by
  `${{ github.sha }}` (and OS/arch when needed).
- Downstream jobs/workflows `download-artifact` / pull from the registry by
  that SHA digests/tags — never re-run the compiler/bundler for the same
  inputs.
- Cross-workflow reuse: same-SHA artifacts, GHCR tags (`sha-<short>`), or a
  remote build cache (Turborepo/Nx/Bazel) authenticated via OIDC.
- Matrix legs that need the same binary: build once, then fan out tests.

### 2. Build only what changed

If inputs have not changed since the last successful build for this SHA or
content hash, **do not rebuild** — restore and reuse.

- Path filters / `dorny/paths-filter` / Nx·Turborepo `affected` to skip
  unaffected packages.
- Content-addressed caches (lockfile + source hash) so identical trees hit.
- Unchanged container layers: registry cache / BuildKit cache, not a full
  rebuild.
- A miss must degrade to a rebuild, never fail the job.

### 3. Progressive depth by PR lifecycle

Early stages focus testing on the change. Developers want quick results on
the initial push or a draft PR. When the PR is marked ready for review,
deepen testing and integrate against existing code.

| Stage | Depth |
| ----- | ----- |
| Push / draft PR | Change-scoped lint, typecheck, unit; smallest matrix; cancel superseded runs |
| Ready for review | Full unit + integration against the **merge target**; broader matrix |
| Merge queue / target branch | Full required checks; no shortcuts |

Implement with `github.event.pull_request.draft`, labels, or separate
workflows (`ci-fast.yml` vs `ci-full.yml`) so draft stays cheap.

### 4. Pass CI against the real merge target

When code is in a PR, it should pass CI only if there is hope to integrate
to the next level. That next level can be `main`, `integration`, or another
branch — it depends on project policy and convention. Always identify the
PR's target and design checks so a green PR is likely to stay green after
merge, minimizing rework and fix churn.

- Prefer `pull_request` with merge-ref checkout (Actions default) over
  head-only checks when integration risk matters.
- Required checks must match what the target branch enforces.
- Do not invent a weaker PR gate than the target requires for the same
  risk class (security, migrations, contracts).

### 5. Containers: build outside DinD; fan out late

When building containers, avoid building inside docker-in-docker (DinD) —
it is slow. Build artifacts on the runner (or BuildKit/buildx on the host)
and copy them into the image.

When building multiple images that share a base:

1. Pull the base **once**.
2. Build shared layers / intermediate images once.
3. Fan out as late as possible into per-service slices that reuse those
   layers.
4. Push with layer reuse (same registry, shared cache, common base digest).

Prefer multi-stage Dockerfiles that `COPY` pre-built binaries over compiling
inside the image when the toolchain is faster on the runner.

## Concurrency

- PR workflows: cancel superseded runs.

  ```yaml
  concurrency:
    group: ${{ github.workflow }}-${{ github.head_ref || github.ref }}
    cancel-in-progress: true
  ```

- Deploy workflows: fixed semantic groups and queue instead of cancel.

  ```yaml
  concurrency:
    group: production-deploy
    cancel-in-progress: false
    queue: max   # up to 100 FIFO; incompatible with cancel-in-progress
  ```

- Build groups from `github.workflow` (the display name) plus the ref.
  Warning: `github.workflow` equals the `name:`, so renaming the workflow
  changes the group key and breaks `workflow_run` triggers that referenced the
  old name. There is no `github.workflow_id` context property (`workflow_id`
  exists only as a numeric field on the REST run object).

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
- Caches complement — do not replace — SHA-keyed build artifacts (rule 1).

## Artifacts

- `actions/upload-artifact` v4 artifacts are immutable. Give each upload a
  unique name (`binary-${{ matrix.os }}-${{ github.sha }}`); re-uploading the
  same name fails.
- Set explicit `retention-days` to control storage cost (short for PR
  intermediates).
- Use `merge-multiple: true` when merging artifacts from several jobs.
- Set `compression-level`: 0 for already-compressed binaries, ~6 for text.
- One build job → many consumer jobs via artifacts is the default shape for
  "build once, reuse".

## Matrices

- Draft / early PR: smallest useful matrix (one OS, primary runtime).
- Ready-for-review / merge queue / target branch: full matrix as policy
  requires.
- `fail-fast: true` normally; `false` for compatibility matrices where you
  want the full failure picture.
- Use `max-parallel` to cap concurrent spend.
- Never rebuild the same artifact inside each matrix leg (rule 1).

## Merge queue

- On busy branches, enable the merge queue and add `merge_group` to the `on:`
  triggers of **every** required workflow. A required workflow without
  `merge_group` stalls the queue.

## Path gating

- `dorny/paths-filter@v4`: tool-agnostic change detection. Treat its `_files`
  outputs as untrusted on PRs (they derive from the diff).
- Nx / Turborepo `affected`: graph-aware, cascades shared-library changes.
  Turborepo Remote Cache can authenticate via OIDC.
- Built-in `on.<event>.paths:`: gates the **whole** workflow only; no per-job
  gating.
- Path gating implements rule 2; still run target-branch confidence checks
  (rule 4) for anything that can break integration.

## Runner choice

- `ubuntu-24.04` is the default; use larger runners only after measurement
  shows a real bottleneck that parallelism can fix.
