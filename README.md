# @t128n/dotfiles

dotfiles repository

## mise

### Preqrequsites

1. [macOS/Linux](https://mise.jdx.dev/installing-mise.html#linux)
2. [Windows](https://mise.jdx.dev/installing-mise.html#windows-script)

`--config-dir` requires mise v2026.10.21 or newer. Run `mise self-update` first if `mise bootstrap` rejects the flag.

### Installation

#### sh

```sh
mise bootstrap --from https://github.com/t128n/dotfiles.git --from-dir "$HOME/Workspace/Repos/github.com/t128n/dotfiles" --config-dir .
```

#### pwsh

```pwsh
mise bootstrap --from https://github.com/t128n/dotfiles.git --from-dir "$HOME\Workspace\Repos\github.com\t128n\dotfiles" --config-dir .
```

## Shell

### bash

Wired automatically via mise's `[dotfiles]` managed lines (see `config.toml`): a line sourcing `shell/bashrc` is added to `~/.bashrc`, and `~/.bash_profile` is made to source `~/.bashrc` for login shells. Deploy with:

```sh
mise dot apply
```

### PowerShell 7

`$PROFILE` isn't a portable path (it can be redirected by OneDrive or corporate policy), so it isn't managed automatically. Add this line to your `$PROFILE` once:

```pwsh
. "$HOME\Workspace\Repos\github.com\t128n\dotfiles\shell\profile.ps1"
```

## Windows Terminal

On Windows, `mise dot apply` copies `windows/terminal/settings.json` to the
stable packaged Windows Terminal's `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`.
The file captures the current profiles, shortcuts, and color schemes. PowerShell
7, the default profile, is installed by `mise run packages:core`.

Close Windows Terminal and back up its existing settings before applying. Copy
deployment overwrites the live file and does not sync UI changes back to the
repository. To keep those changes, review and copy the live settings back into
`windows/terminal/settings.json` before applying again. Other Terminal variants,
such as Preview or unpackaged installs, use different paths and are not managed.

## PowerToys

On Windows, `mise dot apply` copies the selected PowerToys settings from
`windows/powertoys` into `%LOCALAPPDATA%\Microsoft\PowerToys`. The managed
files configure Caps Lock as F24 and schedule app themes to switch at 06:00
and 18:00. Enable Keyboard Manager and Light Switch in PowerToys separately.
Command Palette settings and its activation shortcut are not managed here.

Close PowerToys and back up existing settings before applying. Copy deployment
overwrites the managed files; it does not sync changes made in PowerToys back
to this repository. To keep UI changes, review and copy the corresponding live
JSON files back into `windows/powertoys` before applying again.

## OpenCode

The shared `opencode/opencode.jsonc` is symlinked into the global OpenCode
configuration by `mise dot apply`. Edits to that symlink change the shared
repository file, so keep machine-specific settings in the system configuration
instead:

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

Replace the example with the desired plugin package. Plugin lists from applicable
configuration files are combined; TUI-only plugins use `cli.json` instead.
System configuration applies to all users on the machine and takes precedence
over global and project configuration. Writing it may require administrator
access. It is not managed or restored by this repository; keep secrets out of
version control. See the OpenCode [configuration](https://opencode.ai/v2/docs/config)
and [plugins](https://opencode.ai/v2/docs/plugins) documentation.

## Tasks

### generating ssh key

```sh
ssh-keygen -t ed25519 -C "me@example.com" -f ~/.ssh/id_ed25519
ssh-add ~/.ssh/id_ed25519
```

### auth against git

```sh
gh auth login
gh auth setup-git
```

## Software Stack

mise manages the runtimes and command-line tools in `config.toml`. The optional
package groups below use [WinGet](https://learn.microsoft.com/windows/package-manager/winget/)
on Windows and [Homebrew](https://brew.sh/) on macOS. Install the appropriate
package manager first, then run the tasks from this repository. Linux system
packages are not managed by these groups.

| Task | Software |
| --- | --- |
| `mise run packages:core` | Git, Git LFS, and coreutils; PowerShell 7 on Windows |
| `mise run packages:desktop` | Zed, Zen Browser, DBeaver; Windows Terminal, ShareX, PowerToys, and mRemoteNG on Windows; Ghostty and Shottr on macOS |
| `mise run packages:reverse-engineering` | ImHex and Wireshark; Ghidra on macOS |
| `mise run packages:remote-support` | AnyDesk |
| `mise run packages:diagnostics` | Sysinternals Suite (Windows only) |

Choose only the groups needed on each machine. For example, an AI server might
use Core; a work workstation Core and Desktop; and a personal workstation Core,
Desktop, and Remote Support. No groups are installed automatically, and the
selection is not remembered. Install applications before applying their settings
with `mise dot apply`; see the PowerToys section for precautions.

The Windows manifests are in `windows/packages` and the macOS Brewfiles are in
`macos/packages`. Windows Core uses `Microsoft.Coreutils`; macOS Core uses GNU
coreutils, whose commands are normally prefixed with `g` (for example, `gls`).
On Windows, install [Ghidra](https://ghidra-sre.org/) manually: it was not found
in the WinGet community source. Wireshark live capture on Windows requires
Npcap; review its installer and license separately.

These are install lists, not full desired-state enforcement: removing an entry
does not uninstall the application. Re-running a group may upgrade packages;
use WinGet or Homebrew directly for updates and removals. Installers may prompt
for agreements, elevated permissions, or a restart. Package availability can
vary by OS version and architecture. mise may also install missing configured
tools when running a task, depending on its settings.
