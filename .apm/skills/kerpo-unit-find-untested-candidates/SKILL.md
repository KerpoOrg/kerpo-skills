---
name: kerpo-unit-find-untested-candidates
description: >-
  Use when the user wants to find untested public units worth covering, rank
  retrospective coverage candidates, or pick something to lock after a
  coverage whitelist or ratchet. Apply when existing working code has no
  tests and the task is to propose 1–3 seams — not to write tests. Does not
  activate for red-green or bug-fix patches — that's kerpo-tdd. Does not
  activate for auditing existing tests for anti-patterns — that's
  kerpo-unit-review. Does not activate for generating a test file or "just
  write unit tests."
license: MIT
compatibility: Designed for Claude Code, Cursor, and OpenCode
metadata:
  author: kerpo
  version: "1.0"
---
# kerpo-unit-find-untested-candidates

Ranks 1–3 untested public units worth locking, then stops. Does not write
tests and does not run a TDD cycle. Behavior that should change belongs to
`kerpo-tdd`; tests that already exist belong to `kerpo-unit-review`.

## Instructions

### Step 1 — Detect the repo's test convention

Do not assume colocated `*.test.ts`. Read what this repo actually uses:
Vitest/Jest config, pytest layout, Go `_test.go`, coverage `include` /
whitelist. Match that convention when deciding whether a unit already has
tests. A missing colocated test file is not proof the unit must be tested.

### Step 2 — Scan public units without tests

Look for exported / public API with no tests under the detected convention.
Seams are public boundaries — not private methods, not internals.

### Step 3 — Drop glue before ranking

Discard without ranking: re-exports, generated clients, pages, Docker,
orchestration or store-scale modules. "Untested" is not "must cover."

### Step 4 — Rank 1–3 candidates

Prefer: small public surface, domain behavior, little I/O. Example: a pure
tag parser beats dozens of untested `lib/` glue files. Do not dump the full
untested set.

For each proposal report:

- **Path**
- **Exported public seam**
- **Why cover it**
- **Why neighbors wait**

### Step 5 — Stop and ask

Ask which candidate and which seam to lock. Do not write a test file.

The follow-on (if the user picks a seam) is characterization of **current**
public behavior — independent expected values, no mocks of internals. That
is not this skill and not `kerpo-tdd`.

## Gotchas

- A coverage whitelist / ratchet is a hint about where tests already live,
  not a crusade to cover everything outside it.
- A bug found while exploring untested code is a repro + patch — use
  `kerpo-tdd`. Covering the rest of the working module is optional and
  starts here.
- "Test everything in `lib/`" still yields 1–3 ranked proposals, not a
  dump.
