# @t128n/defaults/fhs

t128n File Hierarchy Standard (FHS) for development workspaces.

```text
$HOME/Workspace/
├── Bin/
├── Repos/
│   ├── .worktrees/
│   └── <host>/<owner>/<repository>/
└── Scratch/
```

## Directories

- **Bin/** — Locally installed CLI tools and executables included in the user `PATH`.
- **Repos/** — Git repositories organized by `<host>/<owner>/<repository>`.
- **Repos/.worktrees/** — Git worktrees organized by `<host>/<owner>/<repository>/<branch>`.
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

### `gwq`

Configure the worktree root:

```sh
gwq config set worktree.basedir "$HOME/Workspace/Repos/.worktrees"
```

Verify:

```sh
gwq config get worktree.basedir
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
