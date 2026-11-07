# @t128n/dotfiles

Declarative Windows and macOS workstation setup, applied with [mise](https://mise.jdx.dev/). The repository is designed to be the global mise configuration: `--config-dir .` links the checkout to `~/.config/mise`, so `config.toml` describes tools, machine-wide packages, and dotfiles in one place.

Linux is not a supported target yet. Package declarations are scoped to `windows` and `macos`.

## Quickstart

Prerequisites:

1. Install [mise](https://mise.jdx.dev/installing-mise.html).
2. On macOS, install [Homebrew](https://brew.sh/) first — the `brew:` entries use it.
3. On Windows, WinGet ships with Windows 10/11.

Then bootstrap the machine:

```sh
mise bootstrap --from https://github.com/t128n/dotfiles.git --from-dir "$HOME/Workspace/Repos/github.com/t128n/dotfiles" --config-dir .
```

```pwsh
mise bootstrap --from https://github.com/t128n/dotfiles.git --from-dir "$HOME\Workspace\Repos\github.com\t128n\dotfiles" --config-dir .
```

`--config-dir` requires mise v2026.10.21 or newer. Run `mise self-update` if the flag is rejected.

After bootstrap, check the result:

```sh
mise run verify
```

## What is managed

| Concern | Owner | Deployed by |
| --- | --- | --- |
| Development tools | `[tools]` in `config.toml` | `mise bootstrap` |
| Machine-wide packages | `[bootstrap.packages]` | `mise bootstrap` |
| User configuration files | `[dotfiles]` | `mise bootstrap` / `mise dot apply` |
| Tool versions | `mise.lock`, `locks/` | committed |

`mise.lock` pins every tool for each supported platform. Update deliberately:

```sh
mise upgrade
mise lock --bump
```

Commit both `mise.lock` and `locks/` with the upgrade.

## Packages

`[bootstrap.packages]` replaces the per-OS manifests that this repository used to carry. The manager prefix selects the native package manager, and `os` and `env` restrict where an entry applies.

### Core

Core installs on every machine, including servers: Git and Git LFS.

Nothing else is installed unless you select a group.

### Optional groups

Groups are mise config environments. Select one with `-E`:

```sh
mise -E desktop bootstrap packages apply
mise -E reverse-engineering bootstrap packages apply
mise -E remote-support bootstrap packages apply
mise -E diagnostics bootstrap packages apply
```

| Group | Windows | macOS |
| --- | --- | --- |
| `desktop` | PowerShell 7, Coreutils, NanaZip, Zed, Windows Terminal, Zen, ShareX, PowerToys, DBeaver, mRemoteNG | coreutils, Zed, Ghostty, Zen, Shottr, DBeaver |
| `reverse-engineering` | ImHex, Wireshark | Ghidra, ImHex, Wireshark |
| `remote-support` | AnyDesk | AnyDesk |
| `diagnostics` | Sysinternals Suite | — |

Preview and inspect a group without changing anything:

```sh
mise -E desktop bootstrap packages status
mise -E desktop bootstrap packages apply --dry-run
```

After the desktop group, apply the browser configuration separately:

```sh
mise run packages:hanok
```

The Hanok installer clones or reuses its checkout, generates the Zen configuration, and applies browser policies. It needs Git on `PATH`. Zen needs an existing profile: open Zen once and quit it completely before running the task. On Windows, applying policies to a Zen installation under Program Files requires an elevated terminal.

### Limits

These declarations are install state, not full ownership:

- WinGet has no `state = "absent"` or `prune`. Deleting an entry does not uninstall the application. Remove it with `winget uninstall`.
- A `"latest"` entry accepts whatever version is installed. Use `mise bootstrap packages upgrade` (add `-E <group>` for optional groups) to update installed packages.
- Homebrew formulae can be pruned explicitly, for example `mise bootstrap packages prune --manager brew --dry-run`. Review the output before running it.
- Installers may prompt for agreements, elevation, or a restart.
- Ghidra is not available from the WinGet community source; install it manually on Windows.

## Verify and drift

```sh
mise run verify
```

The task runs four checks:

1. `mise bootstrap packages status --missing` — core packages differ from the declaration.
2. `mise dot status --missing` — a dotfile is missing or differs.
3. `mise bootstrap status` — tools, packages, dotfiles, and services.
4. `mise doctor` — mise health.

`--missing` makes the first two exit non-zero, so `verify` fails when the machine has drifted. Optional groups are checked only when selected: `mise -E desktop run verify`.

CI runs the same configuration on Linux, macOS, and Windows, but only validates and reports state. It does not install machine-wide packages.

### Copy-mode files

Windows Terminal and PowerToys settings are managed with `mode = "copy"`: the repository wins. When the application rewrites its file, `mise dot status` reports `differs`. Reconcile deliberately:

```sh
mise dot diff           # inspect the difference
mise dot add --changed  # copy intentional live edits back into the repository
mise dot apply          # or discard them and restore the repository version
```

`mise dot add --changed` updates the sources in this repository, so review and commit the result.

## Dotfiles

The `[dotfiles]` table in `config.toml` owns:

| Target | Mode |
| --- | --- |
| `~/.gitconfig` | symlink |
| `~/.gitconfig-identity` | copy, created only when missing |
| `~/.config/starship.toml` | symlink |
| `~/.config/opencode` | symlink each |
| `~/.config/dotfiles/shell/bashrc` | symlink |
| `~/.bashrc` | managed line sourcing the symlink above |
| `~/.bash_profile` | managed line sourcing `~/.bashrc` |
| `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1` | symlink |
| Windows Terminal settings | copy on Windows |
| PowerToys Keyboard Manager and Light Switch settings | copy on Windows |

`~/.config/dotfiles/shell/bashrc` is a stable path, so the managed line in `~/.bashrc` does not depend on where the repository is cloned.

### PowerShell profile

`$PROFILE` is not a portable path: OneDrive or corporate policy can redirect it. The repository therefore deploys to the default `~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`. If your profile lives elsewhere, add this line to it once:

```pwsh
. "$HOME\Workspace\Repos\github.com\t128n\dotfiles\shell\profile.ps1"
```

## OpenCode

The shared `opencode/opencode.jsonc` is symlinked into the global OpenCode configuration. Edits to the symlink change the repository file, so keep machine-specific settings in the system configuration instead:

| Platform | System configuration file |
| --- | --- |
| Windows | `%ProgramData%\opencode\opencode.jsonc` |
| macOS | `/Library/Application Support/opencode/opencode.jsonc` |
| Linux | `/etc/opencode/opencode.jsonc` |

For example, add a plugin on one machine with:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": ["opencode-example-plugin"],
}
```

Plugin lists from applicable configuration files are combined; TUI-only plugins use `cli.json` instead. System configuration applies to all users on the machine and takes precedence over global and project configuration. Writing it may require administrator access. It is not managed or restored by this repository; keep secrets out of version control. See the OpenCode [configuration](https://opencode.ai/v2/docs/config) and [plugins](https://opencode.ai/v2/docs/plugins) documentation.

## Manual tasks

### SSH key

```sh
ssh-keygen -t ed25519 -C "me@example.com" -f ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519
```

### Git authentication

```sh
gh auth login
gh auth setup-git
```

## Workspace layout

See [docs/fhs.md](docs/fhs.md) for the `$HOME/Workspace` convention and how it interacts with `ghq`.
