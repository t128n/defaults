# PowerShell 7 profile — managed by t128n/defaults, edit shell/profile.ps1 in the repo.

if (-not $Host.UI -or -not $Host.UI.RawUI) { return }

[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$OutputEncoding           = [System.Text.UTF8Encoding]::new()
$ErrorView = 'ConciseView'
if ($PSStyle) { $PSStyle.OutputRendering = 'Ansi' }

$env:POWERSHELL_TELEMETRY_OPTOUT  = '1'
$env:DOTNET_CLI_TELEMETRY_OPTOUT  = '1'
$env:AZURE_CORE_COLLECT_TELEMETRY = '0'
$env:POWERSHELL_UPDATECHECK       = 'Off'

$PSDefaultParameterValues['Out-File:Encoding']            = 'utf8'
$PSDefaultParameterValues['Set-Content:Encoding']         = 'utf8'
$PSDefaultParameterValues['Export-Csv:NoTypeInformation'] = $true
$PSDefaultParameterValues['Format-Table:AutoSize']        = $true

# Toolchain
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (& mise activate pwsh) | Out-String | Invoke-Expression
}

# User executables
$env:PATH = "$HOME\Workspace\Bin;$env:PATH"

# Window title + Starship prompt
function global:Update-HostTitle {
    param([string]$Title)
    try {
        if (-not $Title) {
            $loc = (Get-Location).Path
            if ($loc.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
                $loc = "~" + $loc.Substring($HOME.Length)
            }
            $Title = "pwsh: $loc"
        }
        $Host.UI.RawUI.WindowTitle = $Title
    } catch {}
}
function global:Invoke-Starship-PreCommand { Update-HostTitle }

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (& starship init powershell)
} else {
    function global:prompt {
        Update-HostTitle
        "PS $($executionContext.SessionState.Path.CurrentLocation)> "
    }
}
Update-HostTitle

# PSReadLine
if (Get-Module PSReadLine) {
    Set-PSReadLineOption -BellStyle None
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle InlineView
        Set-PSReadLineOption -HistoryNoDuplicates
        Set-PSReadLineOption -Colors @{ InlinePrediction = "$([char]0x1b)[38;5;242m" }
    } catch {}

    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord 'Ctrl+RightArrow' -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView

    Set-PSReadLineOption -AddToHistoryHandler {
        param($command)
        if (-not [string]::IsNullOrWhiteSpace($command)) {
            $firstLine = ($command.Trim() -split "`r?`n")[0]
            if ($firstLine.Length -gt 50) { $firstLine = $firstLine.Substring(0, 47) + "..." }
            Update-HostTitle $firstLine
        }
        return $true
    }

    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        if (-not $env:FZF_DEFAULT_OPTS) {
            $env:FZF_DEFAULT_OPTS = '--color=bg+:#262626,bg:#161616,spinner:#ee5396,hl:#ee5396 --color=fg:#f2f4f8,header:#78a9ff,info:#08bdba,pointer:#3ddbd9 --color=marker:#33b1ff,fg+:#ffffff,prompt:#08bdba,hl+:#33b1ff --layout=reverse --border=rounded --height=40%'
        }
        if (-not $env:RIPGREP_CONFIG_PATH) {
            $rgCandidate = Join-Path $HOME '.config\ripgrep\config'
            if (Test-Path $rgCandidate) { $env:RIPGREP_CONFIG_PATH = $rgCandidate }
        }

        Set-PSReadLineKeyHandler -Chord 'Ctrl+f' -ScriptBlock {
            $fdCmd = if (Get-Command fd -ErrorAction SilentlyContinue) { "fd --type f --strip-cwd-prefix --hidden --exclude .git" } else { "git ls-files" }
            $selected = Invoke-Expression "$fdCmd | fzf"
            if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected) }
        }
        Set-PSReadLineKeyHandler -Chord 'Ctrl+Alt+f' -ScriptBlock {
            if (Get-Command fd -ErrorAction SilentlyContinue) {
                $selected = fd --type d --strip-cwd-prefix --hidden --exclude .git | fzf
                if ($selected) { [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected) }
            }
        }
    }
}

# Unshadow native utilities
foreach ($alias in @('curl', 'wget', 'sc', 'diff')) {
    if (Get-Alias $alias -ErrorAction SilentlyContinue) { Remove-Item "Alias:$alias" -Force -ErrorAction SilentlyContinue }
}

# Prefer GNU coreutils over PowerShell's built-in aliases/functions when installed
$coreutilsBin = Join-Path $env:ProgramFiles 'coreutils\bin'
if (Test-Path -LiteralPath $coreutilsBin -PathType Container) {
    foreach ($name in @('cat', 'cp', 'date', 'echo', 'ls', 'mkdir', 'mv', 'pwd', 'rm', 'rmdir', 'sleep', 'sort', 'tee', 'uptime')) {
        foreach ($drive in @('Alias', 'Function')) {
            if (Get-Item "${drive}:$name" -ErrorAction SilentlyContinue) { Remove-Item "${drive}:$name" -Force -ErrorAction SilentlyContinue }
        }
    }
}

# Git shortcuts
function global:g    { git $args }
function global:gst  { git status $args }
function global:gco  { git checkout $args }
function global:gsw  { git switch $args }
function global:gcb  { git checkout -b $args }
function global:gd   { git diff $args }
function global:gl   { git log --oneline --graph --decorate -n 20 $args }
function global:gcm  { git commit -m $args }
function global:gp   { git push $args }
function global:gpl  { git pull $args }

# Directory traversal & workspace navigation
function global:..   { Set-Location .. }
function global:...  { Set-Location ../.. }
function global:.... { Set-Location ../../.. }

function global:mkcd {
    param([Parameter(Mandatory=$true)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location $Path
}

function global:ws {
    param([string]$Sub = '')
    switch ($Sub.ToLower()) {
        'repos'  { Set-Location 'C:\Workspace\Repos'; break }
        'portal' { Set-Location 'C:\Workspace\Portal'; break }
        'cache'  { Set-Location 'C:\Workspace\Cache'; break }
        'spikes' { Set-Location 'C:\Workspace\Spikes'; break }
        'setup'  { Set-Location 'C:\Workspace\Setup'; break }
        default  { Set-Location 'C:\Workspace'; break }
    }
}
function global:portal { Set-Location 'C:\Workspace\Portal' }

# Quality of life
function global:Test-Admin {
    if ($IsWindows) {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p = [Security.Principal.WindowsPrincipal]::new($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    return ($env:USER -eq 'root')
}

function global:which {
    param([Parameter(Mandatory=$true)][string]$Name)
    Get-Command $Name -ErrorAction SilentlyContinue | Format-Table -Property CommandType, Name, Version, Source -AutoSize
}

function global:touch {
    param([Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)][string[]]$Paths)
    foreach ($p in $Paths) {
        if (Test-Path $p) { (Get-Item $p).LastWriteTime = [DateTime]::Now }
        else { New-Item -ItemType File -Path $p -Force | Out-Null }
    }
}
