# @t128n/defaults/fhs

t128n File Hierarchy Standard (FHS) for development workspaces.

```text
$HOME/Workspace/
├── Bin/
├── Repos/
│   └── <host>/<owner>/
│       ├── <repository>/
│       └── #<repository>-<branch>/
└── Scratch/
```

## Directories

- **Bin/** — Locally installed CLI tools and executables included in the user `PATH`.
- **Repos/** — Git repositories organized by `<host>/<owner>/<repository>`.
- **Repos/<host>/<owner>/#<repository>-<branch>/** — Git worktrees, siblings of their repository. The `#` prefix sets them apart from normal repositories at a glance, with no separate worktree directory to maintain. Created and removed with the `wa`/`wr` git aliases (see `git/gitconfig`).
- **Scratch/** — Disposable experiments, prototypes, and temporary files.

## Configuration

### `ghq`

Configure the repository root:

```sh
git config --global ghq.root "$HOME/Workspace/Repos"
```

Verify:

```sh
ghq root
```

### `PATH`

Add `Workspace/Bin` to the user `PATH`.

#### Windows (PowerShell)

```powershell
$bin = "$HOME\Workspace\Bin"
$path = [Environment]::GetEnvironmentVariable("Path", "User")

if ($bin -notin ($path -split ";")) {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$($path.TrimEnd(';'));$bin",
        "User"
    )
}
```

Restart the terminal to apply the change.

#### macOS / Linux

Add to `~/.bashrc`:

```sh
export PATH="$HOME/Workspace/Bin:$PATH"
```

Apply to the current session:

```
source ~/.bashrc
```
