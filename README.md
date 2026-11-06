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

1. Zed - IDE
2. Ghostty terminal / Windows Terminal
3. Zen Browser
4. ShareX / Shottr screenshot tool
5. PowerToys
