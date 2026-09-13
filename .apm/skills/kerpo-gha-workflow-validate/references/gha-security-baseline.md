# GitHub Actions security baseline

Non-negotiable defaults for every workflow. Apply from the first line; do not
retrofit after a review finds gaps.

## 1. Default-deny permissions

- Set a top-level `permissions:` with the minimum: `contents: read` for most
  CI, or `{}` when nothing needs the token.
- Elevate **per job only** for what that job actually needs (`id-token: write`
  for OIDC, `packages: write` for a publish job, `pull-requests: write` for a
  comment bot).
- Never rely on the repository default (often read/write all). If there is no
  top-level block, every job inherits the full default token.

```yaml
permissions:
  contents: read
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
```

## 2. SHA-pin every third-party action

- Pin to a full commit SHA with the human version as a trailing comment:
  `uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683 # v4.2.2`
- Never `@main`, `@master`, or any branch ref.
- Never a bare moving major tag (`@v4`) for third-party actions. The
  `tj-actions/changed-files` compromise (CVE-2025-30066, Mar 2025) is the
  canonical reason: a mutable tag let an attacker repoint every consumer at
  once.
- Floating major tags are acceptable **only** for first-party actions inside
  the same organization, where you control the tag.

## 3. OIDC instead of long-lived cloud credentials

- Use `permissions: id-token: write` and exchange the OIDC token for short
  cloud sessions (AWS, GCP, Azure, Vault). No static access keys in secrets.
- Scope the cloud trust policy to the exact workflow identity, ideally
  `job_workflow_ref` (also called "sub" / subject claim), plus environment or
  ref. Example AWS trust condition:

  ```json
  "StringLike": {
    "token.actions.githubusercontent.com:sub":
      "repo:org/repo:ref:refs/heads/main",
    "token.actions.githubusercontent.com:job_workflow_ref":
      "org/repo/.github/workflows/deploy.yml@refs/heads/main"
  }
  ```

- Repos created after Jul 2026 emit immutable `sub` claims containing owner and
  repository IDs. Trust policies written against the mutable name form must be
  updated; the ID form is stable across renames.

## 4. Template injection

- Never interpolate untrusted event data directly into `run:`:
  `${{ github.event.pull_request.title }}`, branch names, issue bodies,
  commit messages, `github.head_ref`, etc. An attacker controls those and can
  break out of the shell string.
- Route untrusted values through `env:` and reference the env var in the
  shell:

  ```yaml
  - name: Greet
    env:
      PR_TITLE: ${{ github.event.pull_request.title }}
    run: echo "PR: $PR_TITLE"
  ```

- Avoid `pull_request_target` combined with checking out the PR head. If you
  must use it, never run code from the fork; `pull_request` gives a read-only
  token and no secrets.

## 5. Guard the workflows themselves

- Run `actionlint` and `zizmor` in CI over `.github/workflows/` so workflow
  changes are linted and security-scanned like code.
- Add `CODEOWNERS` covering `.github/workflows/` so changes need a reviewer.
- Prefer pinned versions of these tools too (or run them from a pinned image).

## 6. Keep pins fresh without losing the pin

- Dependabot: `package-ecosystem: github-actions`, weekly, keeps SHA pins and
  updates the version comment.
- Renovate: enable `helpers:pinGitHubActionDigestsToSemver` (or
  `pinGitHubActionDigests`) plus `minimumReleaseAge` of 7-14 days to dodge
  day-0 supply-chain releases.
- Org policy can enforce full-SHA pinning and an action allowlist/blocklist so
  an unapproved action cannot be introduced.

## 7. Secrets hygiene

- Map secrets explicitly (`${{ secrets.X }}`) rather than
  `secrets: inherit`. `inherit` hands every secret to a called workflow that
  may not need them.
- Precedence: an environment secret overrides a repository secret of the same
  name; repository overrides organization. Do not shadow names by accident.
- Fork PRs receive a read-only `GITHUB_TOKEN` and no secrets. Do not design a
  workflow that only works if forks get secrets.
- Mask derived values (hashes, composed tokens) with `::add-mask::` before
  echoing or passing them on.
- Never cache or artifact secrets; see the perf playbook for cache write
  scoping.

## Review checklist

- [ ] Top-level `permissions` set and minimal
- [ ] Per-job elevation only where required
- [ ] All third-party `uses:` pinned to full SHA + version comment
- [ ] Cloud auth via OIDC, trust scoped to `job_workflow_ref`
- [ ] No `${{ }}` of untrusted event data inside `run:`
- [ ] No `pull_request_target` + fork-head checkout
- [ ] `actionlint` + `zizmor` run on the workflows; `CODEOWNERS` present
- [ ] Pin-update automation configured; full-SHA policy enforced
- [ ] No `secrets: inherit` unless same-org and justified
- [ ] Derived values masked
