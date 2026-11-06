# @t128n/defaults

defaults repository

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
