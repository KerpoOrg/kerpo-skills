---
name: kerpo-unit-review
description: >-
  Use when auditing or reviewing existing tests for anti-patterns —
  implementation-coupled tests that mock internals or test private methods,
  or tautological assertions that recompute the expected value the way the
  code does. Apply during code review of a test suite, or before trusting
  legacy tests you didn't write test-first. Does not activate for writing new
  tests test-first or running a red-green cycle — that's kerpo-tdd. Does not
  activate for finding untested working units or retrospective coverage —
  that's kerpo-unit-find-untested-candidates.
license: Proprietary
compatibility: Designed for Claude Code and Cursor
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-unit-review

Audits existing tests against the TDD anti-pattern taxonomy — for tests
already written, not for tests you're writing test-first (see `kerpo-tdd`
for that loop) and not for units that have no tests yet (see
`kerpo-unit-find-untested-candidates`).

## Anti-patterns to check

### Implementation-coupled

Mocks internal collaborators, tests private methods, or verifies through a
side channel (e.g. querying the database directly instead of using the
interface under test). The tell: the test breaks when you refactor even
though behavior hasn't changed.

### Tautological

The assertion recomputes the expected value the same way the code does
(`expect(add(a, b)).toBe(a + b)`, a snapshot derived by hand the same way, a
constant asserted equal to itself) — it passes by construction and can never
disagree with the code. Expected values must come from an independent source
of truth: a known-good literal, a worked example, the spec.

See [references/good-tests.md](references/good-tests.md) for what a passing
test should look like instead, and [references/mocking.md](references/mocking.md)
for when mocking is (and isn't) appropriate.

## Instructions

For each test under review:

1. Identify the seam it tests at (public interface vs. internals)
2. Check whether it's implementation-coupled, tautological, both, or neither
3. Report: test name → anti-pattern found (or none) → concrete suggested fix,
   ideally showing what an independent-source-of-truth assertion or
   seam-level rewrite would look like

## Gotchas

- A test can fail both checks at once — report each anti-pattern separately,
  don't stop at the first match.
- Don't flag a test just because it uses a mock — only flag it if the mock
  stands in for an *internal* collaborator. Mocking a genuine external
  boundary (network, filesystem, time, third-party service) is expected; see
  references/mocking.md.
- This skill doesn't rewrite tests unless asked — default to reporting
  findings, then ask before changing test code.
