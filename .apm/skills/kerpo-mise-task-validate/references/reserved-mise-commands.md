# Reserved mise CLI names (task denylist)

Task names and task aliases must not appear in this list. Built-in mise
subcommands win over `mise <TASK>` shorthand.

**Refresh:** re-parse `mise --help` Commands (+ `[aliases: …]`) when mise majors
bump. Seed generated from mise 2026.6.x help.

## Commands

```
activate
backends
bin-paths
bootstrap
cache
completion
config
deactivate
deps
doctor
dotfiles
edit
en
env
exec
fmt
generate
help
implode
install
install-into
latest
link
lock
ls
ls-remote
mcp
oci
outdated
patrons
plugins
prune
registry
reshim
run
search
self-update
set
settings
shell
shell-alias
sponsors
sync
tasks
test-tool
token
tool
tool-alias
tool-stub
trust
uninstall
unset
untrust
unuse
upgrade
use
version
watch
where
which
```

## Short aliases (also reserved)

```
cfg
dep
dr
e
gen
i
list
ln
p
r
rm
remove
sh
t
u
up
v
w
x
```

## Rename guidance

| Bad task name | Safer approach |
|---------------|----------------|
| `install` / `uninstall` | Domain task + subcmd, e.g. `skills` → `install` |
| `run` / `tasks` / `exec` | Different domain verb or compound not in this list |
| One-letter names matching aliases | Never |

Namespaced names (`db:migrate`) are fine if the **full** task name and any
alias are not in the denylist (the segment after `:` is not checked alone
unless it is also registered as an alias for the whole task).
