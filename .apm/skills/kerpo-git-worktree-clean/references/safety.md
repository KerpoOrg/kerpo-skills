# Worktree clean — safety

## Human-only

Cleanup runs only on an explicit human request in the current turn. Never as a
side effect of merge, closeout, handoff, or another skill.

## Confirm before destructive steps

- Ambiguous “clean up worktrees” → list paths, confirm each
- Dirty worktree → ask before discard/force
- Local branch delete → ask unless user already ordered it
- Remote branch delete → only on explicit ask
- Reserved worktrees (from conventions) → only if user named them

## Order

1. Confirm targets  
2. Dirty gate  
3. Project pre-destroy teardown (if documented)  
4. `git worktree remove` + `prune`  
5. Optional branch delete (confirmed)  
6. Optional primary residue check (if documented)
