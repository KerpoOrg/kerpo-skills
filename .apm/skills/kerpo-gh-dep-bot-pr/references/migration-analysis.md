# Migration analysis

Core path: changelogs → local usage → package special instructions → impact
class → action (`merge_ok` / `fix_on_branch` / `major_migration`).

## 1) Scrape changelogs (per package)

For each `{ name, from, to }` in `DepUpdate.packages[]`, gather notes covering
releases from `from` to `to`.

### Source priority

1. Links / excerpts already in the bot PR body (`changelogHints`)
2. GitHub Releases / tags compare URL / `CHANGELOG.md` / `HISTORY.md` /
   `CHANGES.md` in the package repository
3. Registry metadata (npm `repository` / `homepage`, PyPI project URLs, etc.)
4. If nothing usable → `changelog: missing` → **cannot** recommend `merge_ok`

### Extract

- Breaking changes
- Deprecations affecting APIs this repo might call
- Required config / peer dependency changes
- Security notes
- Links to migration / upgrade guides

Summarize in bullets; quote only when needed for precision.

## 2) Local usage scan

Search the **consuming repo** (not only lockfiles):

- Imports / requires / use statements for the package
- Config that references it (eslint extends, bundler plugins, CI actions, etc.)
- Call sites of APIs named in breaking/deprecation notes

Output an **impact map**:

```text
package@from→to
  - used in: path:line (symbol)
  - changelog item → required change: none | rename | config | rewrite
```

If the package is only a transitive dependency with no direct import/config
hit, say so explicitly (still read changelog for security).

## 3) Special instructions

Beyond raw changelog:

- `MIGRATION.md`, `UPGRADING.md`, “Upgrade guide” links from README
- Known high-impact ecosystem guides (e.g. Next.js / React majors) when
  applicable
- Notes Renovate embedded in the PR body

These feed the same impact map.

## 4) Impact classification

| Impact | Criteria | Action |
|--------|----------|--------|
| `none` | No breaking notes affecting used APIs; usage clean; (later) CI green | `merge_ok` after confirm |
| `small` | Bounded renames, import paths, config one-liners, type-only tweaks | `fix_on_branch` after confirm |
| `major` | Broad rewrite, framework major, multi-package cascade, unclear blast radius, many files | `major_migration` → separate GitHub issue; block dep PR merge |

Grouped updates: **worst** package impact wins.

When unsure between `small` and `major`, choose **`major`** (fail closed toward
a dedicated issue rather than a risky drive-by fix).

## 5) Action details

### fix_on_branch

- `gh pr checkout <n>` (resolve worktree with `kerpo-git-context` if needed)
- Minimal diffs only for mapped call sites
- Commit message should reference the bump (package + versions)
- Push to the bot branch; re-run / wait for CI; only then suggest merge

### major_migration issue body (template)

```markdown
## Dependency PR

<url>

## Packages

- `name`: from → to

## Why a separate migration

<summary of breaking changes and blast radius>

## Usage impact

- <file / API findings>

## Migration plan

- [ ] …

## Acceptance criteria

- [ ] …

## Merge policy

Do **not** merge the dependency PR until this issue is completed.
```

Optionally comment on the dep PR with the new issue URL and “blocked on migration”.
