# Good tests — reference

Detailed guidance on what makes a test worth keeping. Loaded on demand by
`kerpo-tdd` and `kerpo-tdd-review`.

## The core rule

Tests verify **behavior** through **public interfaces**, not implementation
details. Code can change entirely — tests shouldn't need to. A good test
reads like a specification: its name alone tells you what capability exists.

## Example

Bad (implementation-coupled — names an internal method, not a capability):

```
test("calls validateCart() then chargeCard()")
```

Good (specification-style — names the capability, observed through the
public interface):

```
test("user can checkout with a valid cart")
```

## Why this matters

A test suite that mirrors your class/function structure needs rewriting
every time you refactor that structure, even when nothing observable
changed. A test suite that mirrors user-facing behavior survives refactors
and only needs to change when behavior actually changes.
