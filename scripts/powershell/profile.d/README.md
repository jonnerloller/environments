# PowerShell Profile Scripts

Put `.ps1` files in this folder when they should be dot-sourced into every PowerShell session.

Files load in filename order from `../profile.ps1`, so use numeric prefixes such as `10-aliases.ps1` when order matters.

## Jujutsu Shortcuts

`20-jj-shortcuts.ps1` adds these PowerShell shortcuts:

- `jj push "commit message" [bookmark]` describes `@`, moves the bookmark to `@`, then pushes that bookmark.
- `jj merge-main <source-bookmark> [message]` creates a merge commit from the source bookmark into `main`, moves `main` to the merge commit, then pushes `main`.
- `jjp` and `jjmm` are aliases for the two shortcuts.

Normal `jj ...` commands still pass through to `jj.exe`.
