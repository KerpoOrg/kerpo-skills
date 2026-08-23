# Flavours

Plugin-style adapters for dependency bots. The shared skill pipeline never
hard-codes Renovate-only logic beyond calling the active flavour.

## Contract

Each flavour provides:

1. **`detect(pr)`** — true if this PR belongs to the bot
2. **`parse(pr)`** — normalized `DepUpdate`
3. **`changelogHints(pr)`** — URLs / body sections already embedded by the bot
4. **`hints`** — labels, dashboard notes, branch conventions (optional)

### Normalized `DepUpdate`

```text
flavour: renovate | dependabot | unknown
packages[]: { name, from, to, ecosystem? }
updateKind: patch | minor | major | pin | digest | lockfile | security | unknown
isGrouped: boolean
isSecurity: boolean
confidence: high | low
```

Detection order: try **renovate**, then **dependabot**, else `unknown`
(fail closed — see safety policy).

Detailed adapters:

- [flavours/renovate.md](flavours/renovate.md) — v1 full
- [flavours/dependabot.md](flavours/dependabot.md) — v1 stub

## Adding a future flavour

1. Add `references/flavours/<name>.md` implementing the contract.
2. Register it in the detection order above.
3. Keep `SKILL.md` control flow unchanged (detect → parse → migration → gates).
