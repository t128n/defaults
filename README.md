# @t128n/dotfiles

dotfiles repository

## mise

### Preqrequsites

1. [macOS/Linux](https://mise.jdx.dev/installing-mise.html#linux)
2. [Windows](https://mise.jdx.dev/installing-mise.html#windows-script)

### Installation

#### sh

```sh
mise bootstrap --from https://github.com/t128n/defaults.git --from-dir "$HOME/Workspace/Repos/github.com/t128n/defaults" --config-dir mise
```

#### pwsh

```pwsh
mise bootstrap --from https://github.com/t128n/defaults.git --from-dir "$HOME\Workspace\Repos\github.com\t128n\defaults" --config-dir mise
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
. "$HOME\Workspace\Repos\github.com\t128n\defaults\shell\profile.ps1"
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
