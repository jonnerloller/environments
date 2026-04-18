# PowerShell Scripts

Use this folder for PowerShell automation that should live with the environment repo.

- `profile.ps1` is the shared profile entrypoint sourced by the machine's stock PowerShell profile.
- `profile.d/*.ps1` files are dot-sourced on PowerShell startup in filename order.
- Keep one-off automation scripts here, but outside `profile.d`, when they should not run for every shell.

Do not commit secrets, tokens, or machine-private credentials.
