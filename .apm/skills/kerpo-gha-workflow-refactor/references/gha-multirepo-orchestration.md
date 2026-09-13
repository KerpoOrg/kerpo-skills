# Cross-repository orchestration

Patterns for fan-out/fan-in, staged deploys, and failure handling across
repositories. Prefer the simplest pattern that meets the need; most "multi-repo
mayhem" is avoidable.

## Outbound triggers

- **`repository_dispatch` (fan-out).** POST to the target repo's dispatches
  API with a `client_payload` carrying `sha`, `env`, and a `trace_id`; filter
  with `types:` on the receiving `on:` block. Fire-and-forget: you get no
  result back, so you must design fan-in separately.
- **`GITHUB_TOKEN` does not trigger downstream workflows.** Use a GitHub App
  token from `actions/create-github-app-token@v3` (1-hour, auto-revoked,
  `[bot]` actor in the audit log) or an OIDC-exchanged token.
- Rate limit: ~150 concurrent dispatches per 10 seconds.
- **`workflow_dispatch` + API** with `gh run watch` gives a quasi-synchronous
  call. The target workflow must already exist on the default branch.
- **Cross-repo `workflow_call`** (`uses: org/repo/.github/workflows/x.yml@{sha}`)
  runs in-process inside the caller: `outputs`, `needs`, and matrix all work
  normally. Two caveats: the called workflow's permissions run in the
  **caller's** context, and cache access is capped unless `cache-mode` is set.

## Fan-in

- Children report back with a commit status / check-run, or a Deployment
  status, tagged with the correlation `trace_id`.
- The orchestrator polls those statuses with a timeout and a sweeper for
  stragglers.
- If the polling glue exceeds ~200 lines, graduate to an external orchestrator
  (Argo Workflows, Temporal, Dagger).

## Topology

- A **central orchestrator repo** owns the DAG and sequencing; satellite
  repos keep thin triggers only.
- Anti-pattern: satellites calling each other directly. That creates a hidden,
  unowned web of dependencies. Route through the orchestrator.

## Staged cross-repo deploys

- Use GitHub Environments with required reviewers and wait timers to gate.
- Track "what's where" with Deployment API statuses.
- Concurrency per app and environment:
  `deploy-${{ env }}-${{ app }}` with **no** cancel-in-progress, so a running
  deploy is never interrupted.
- Sequence explicitly: the orchestrator awaits the backend deployment before
  dispatching the frontend.

## Failure handling

- Retry flaky **tests** only (`nick-fields/retry` or equivalent). Never retry
  deploys automatically.
- `fail-fast: false` keeps sibling jobs alive so one failure does not hide
  others.
- Key idempotent steps on immutable inputs (commit SHA, image digest,
  deployment id), never `latest`. Re-running then converges instead of
  duplicating.
- Use `workflow_dispatch` plus `run_attempt` for deliberate run retries.

## Observability

- Start with the native Actions UI plus a Slack notification.
- Once more than ~20 workflows are active, add Datadog CI Visibility or
  Grafana with API scraping, or forward `workflow_job` webhooks to
  OpenTelemetry.
- Alert on trends (p95 queue time, failure rate), not on single failures.
