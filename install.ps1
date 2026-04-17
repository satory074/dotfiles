#Requires -Version 7.0
# install.ps1 - Windows dotfiles setup (PowerShell)
# Usage: pwsh -File install.ps1 [-SkipPackages]
# Requires Developer Mode or Administrator for symlink creation.

param(
    [switch]$SkipPackages
)

$ErrorActionPreference = 'Stop'
$DOTFILES = $PSScriptRoot

function Write-Step { param($msg) Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Skip  { param($msg) Write-Host "    skip: $msg" -ForegroundColor DarkGray }
function Write-OK    { param($msg) Write-Host "    ok:   $msg" -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host "    warn: $msg" -ForegroundColor Yellow }

# --- Symlink capability check ---
function Test-SymlinkCapability {
    $testLink = "$env:TEMP\dotfiles_symlink_test_$(Get-Random)"
    try {
        New-Item -ItemType SymbolicLink -Path $testLink -Target $env:TEMP -ErrorAction Stop | Out-Null
        Remove-Item $testLink -Force
        return $true
    } catch {
        return $false
    }
}

if (-not (Test-SymlinkCapability)) {
    Write-Error @"
Cannot create symbolic links.
Please either:
  1. Enable Developer Mode: Settings → System → Developer options → Developer Mode ON
  2. Run this script as Administrator
"@
    exit 1
}

# --- Symlink helper (idempotent) ---
function New-Symlink {
    param(
        [string]$Src,
        [string]$Dst
    )
    if (-not (Test-Path $Src)) {
        Write-Warn "source not found, skipping: $Src"
        return
    }
    if (Test-Path $Dst -PathType Any) {
        $item = Get-Item $Dst -Force
        if ($item.LinkType -eq 'SymbolicLink') {
            $target = $item.Target
            # Normalize paths for comparison
            if ([System.IO.Path]::GetFullPath($target) -eq [System.IO.Path]::GetFullPath($Src)) {
                Write-Skip $Dst
                return
            }
        }
        Remove-Item $Dst -Force -Recurse
    }
    $parent = Split-Path $Dst
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path $Dst -Target $Src | Out-Null
    Write-OK "$Dst → $Src"
}

# ============================================================
# 1. Install packages via winget
# ============================================================
if (-not $SkipPackages) {
    Write-Step "Installing packages via winget"
    $pkgFile = Join-Path $DOTFILES 'winget-packages.json'
    if (Test-Path $pkgFile) {
        winget import --import-file $pkgFile --ignore-versions --no-upgrade
    } else {
        Write-Warn "winget-packages.json not found — skipping package install"
    }
}

# ============================================================
# 2. Install clasp (Google Apps Script CLI) via npm
# ============================================================
if (-not $SkipPackages) {
    Write-Step "Installing clasp (Google Apps Script CLI)"
    if (Get-Command fnm -ErrorAction SilentlyContinue) {
        fnm env --use-on-cd | Out-String | Invoke-Expression
    }
    if (Get-Command npm -ErrorAction SilentlyContinue) {
        $claspInstalled = npm list -g @google/clasp --depth=0 2>$null |
                          Select-String '@google/clasp'
        if ($claspInstalled) {
            Write-Skip "@google/clasp already installed"
        } else {
            npm install -g @google/clasp
            Write-OK "@google/clasp installed"
        }
    } else {
        Write-Warn "npm not found — skipping clasp install. Run manually: npm install -g @google/clasp"
    }
}

# ============================================================
# 3. Create symlinks
# ============================================================
Write-Step "Creating symlinks"

$links = @(
    # Shell files
    @{ Src = "$DOTFILES\.gitconfig";  Dst = "$HOME\.gitconfig" }
    @{ Src = "$DOTFILES\.vimrc";      Dst = "$HOME\.vimrc" }
    @{ Src = "$DOTFILES\.vimrc_vs";   Dst = "$HOME\.vimrc_vs" }

    # PowerShell profile
    @{ Src = "$DOTFILES\.config\powershell\Microsoft.PowerShell_profile.ps1"
       Dst = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" }

    # Neovim
    @{ Src = "$DOTFILES\.config\nvim"; Dst = "$HOME\.config\nvim" }

    # Claude Code
    @{ Src = "$DOTFILES\.claude\CLAUDE.md";   Dst = "$HOME\.claude\CLAUDE.md" }
    @{ Src = "$DOTFILES\.claude\commands";    Dst = "$HOME\.claude\commands" }
    @{ Src = "$DOTFILES\.claude\hooks";       Dst = "$HOME\.claude\hooks" }
    @{ Src = "$DOTFILES\.claude\statusline-command.ps1"
       Dst = "$HOME\.claude\statusline-command.ps1" }

    # Codex
    @{ Src = "$DOTFILES\.codex\hooks"; Dst = "$HOME\.codex\hooks" }
)

foreach ($link in $links) {
    New-Symlink -Src $link.Src -Dst $link.Dst
}

# ============================================================
# 4. settings.json (copy from sample if not present)
# ============================================================
Write-Step "Setting up .claude/settings.json"
$settingsDst = "$HOME\.claude\settings.json"
$settingsSrc = "$DOTFILES\.claude\settings.json.sample"
if (-not (Test-Path $settingsDst)) {
    if (Test-Path $settingsSrc) {
        Copy-Item $settingsSrc $settingsDst
        Write-OK "settings.json created from sample"
    } else {
        Write-Warn "settings.json.sample not found"
    }
} else {
    Write-Skip "settings.json already exists"
}

# ============================================================
# 5. Git hooks path
# ============================================================
Write-Step "Configuring git hooks"
Push-Location $DOTFILES
git config core.hooksPath .git-hooks
Pop-Location
Write-OK "core.hooksPath = .git-hooks"

# ============================================================
# Done
# ============================================================
Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host "Restart PowerShell (or run `. `$PROFILE`) to apply profile changes." -ForegroundColor Green
