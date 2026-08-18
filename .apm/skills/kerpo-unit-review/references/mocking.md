# Mocking — reference

Guidance on when to mock. Loaded on demand by `kerpo-tdd` and
`kerpo-unit-review`.

## The core rule

Mock only genuine external boundaries: network calls, the filesystem, the
system clock, third-party services you don't control. Never mock an internal
collaborator — a class, function, or module that lives inside the codebase
under test.

## Why

Mocking an internal collaborator couples the test to today's internal
structure. When you refactor that collaborator away, the test breaks even
though the observable behavior of the system hasn't changed — this is the
"implementation-coupled" anti-pattern (see `kerpo-unit-review`).

## Rule of thumb

Before mocking anything, ask: "If I deleted this dependency and inlined its
code, would this still be the same architectural boundary?" If yes (it's a
real seam — a database, an HTTP client, a payment gateway), mocking it is
fine. If no (it's just how you happened to factor the code today), don't
mock it — test through the real collaborator instead, at a seam further out.
