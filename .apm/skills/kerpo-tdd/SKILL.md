---
name: kerpo-tdd
description: >-
  Use when the user wants to build features or fix bugs test-first, mentions
  "red-green-refactor," or wants integration tests written test-first. Apply
  when starting a new TDD cycle: confirming test seams, writing a failing
  test, then the minimal code to pass it. Does not activate for auditing or
  reviewing already-written/legacy tests for anti-patterns without doing new
  work — that's kerpo-unit-review. Does not activate for finding untested
  working units or retrospective gap-fill — that's
  kerpo-unit-find-untested-candidates.
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.1"
---
# kerpo-tdd

TDD is the red → green loop. This skill is the reference that makes that loop
produce tests worth keeping: what a good test is, where tests go, and the
rules of the loop. Every section applies on every cycle — consult them before
and during the loop, not after.

When exploring the codebase, read `CONTEXT.md` (if it exists) so test names
and interface vocabulary match the project's domain language, and respect
ADRs in the area you're touching.

## What a good test is

Tests verify behavior through public interfaces, not implementation details.
Code can change entirely; tests shouldn't. A good test reads like a
specification — "user can checkout with valid cart" tells you exactly what
capability exists — and survives refactors because it doesn't care about
internal structure.

See [references/good-tests.md](references/good-tests.md) for examples and
[references/mocking.md](references/mocking.md) for mocking guidelines.

## Step 0 — Seams: where tests go

A **seam** is the public boundary you test at: the interface where you
observe behavior without reaching inside. Tests live at seams, never against
internals.

**Test only at pre-agreed seams.** Before writing any test, write down the
seams under test and confirm them with the user. No test is written at an
unconfirmed seam. You can't test everything — agreeing the seams up front is
how testing effort lands on the critical paths and complex logic instead of
every edge case.

Ask: "What's the public interface, and which seams should we test?"

## Rules of the loop

- **Red before green.** Write the failing test first, then only enough code
  to pass it. Don't anticipate future tests or add speculative features.
- **One slice at a time.** One seam, one test, one minimal implementation per
  cycle. Don't write all the tests first and then all the implementation
  ("horizontal slicing") — bulk tests verify *imagined* behavior: you test
  the shape of things rather than user-facing behavior, the tests go
  insensitive to real changes, and you commit to test structure before
  understanding the implementation. Work in vertical slices instead — one
  test → one implementation → repeat, each test a tracer bullet that responds
  to what the last cycle taught you.
- **Refactoring is not part of the loop.** It belongs to the review stage
  (see the `code-review` skill), not the red → green implementation cycle.

For anti-pattern review of already-written tests (implementation-coupled
tests, tautological assertions), use `kerpo-unit-review` instead. For
finding untested working units to lock later, use
`kerpo-unit-find-untested-candidates`. This skill governs writing new tests
test-first, not auditing existing ones or ranking coverage gaps.

## Gotchas

- Don't write a test at a seam the user hasn't confirmed — that's how testing
  effort drifts onto trivial paths instead of critical ones.
- An assertion that recomputes the expected value the way the code does
  (e.g. `expect(add(a, b)).toBe(a + b)`) passes by construction — expected
  values must come from an independent source of truth even inside this
  loop, not just when auditing old tests.
