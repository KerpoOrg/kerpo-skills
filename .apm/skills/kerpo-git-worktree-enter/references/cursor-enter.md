# Cursor: entering a worktree

After selecting an existing worktree path (absolute):

1. Prefer Cursor **`move_agent_to_root`** with `rootPath` set to that path.
2. Call it **before** editing files in the worktree so terminals and the
   visible root match the checkout.
3. Use **`move_agent_to_cloned_root`** only for a verbatim `cursorfs-clone`
   sibling already on the recorded branch — not for normal `git worktree add`
   paths. `move_agent_to_root` may fetch `origin/<branch>` and fail on
   local-only branches; for local-only linked worktrees, still use
   `move_agent_to_root` on the worktree path (it is a real checkout, not a
   cursorfs clone).

If the move tool is unavailable, ask the user to open the folder as the
workspace root, then verify with `git -C <path>`.
