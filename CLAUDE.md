# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS / WSL2 / Linux + zsh, and **native Windows PowerShell**, managed via symlinks.

- **macOS / WSL2 / Linux**: `install.sh` creates symlinks (zsh + `.sh` hooks)
- **Windows (native PowerShell)**: `install.ps1` creates symlinks (PowerShell profile + `.ps1` hooks)

## Installing / Applying Changes

### Windows (native PowerShell)

```powershell
# Developer Mode を有効にするか、管理者として実行
pwsh -File ~/dotfiles/install.ps1          # winget インストール + symlink 作成（冪等）
. $PROFILE                                 # プロファイルをリロード
winget import --import-file ~/dotfiles/winget-packages.json --ignore-versions  # パッケージのみ再実行
```

### macOS / WSL2 / Linux (zsh)

```bash
bash ~/dotfiles/install.sh        # Full setup: OS 検出・依存インストール・symlink 作成（冪等）
source ~/.zshrc                   # Reload shell config after .zshrc edits
zsh -n ~/.zshrc                   # Syntax check .zshrc without sourcing
DOTFILES=~/dotfiles bash ~/dotfiles/test/bootstrap-check.sh  # 構成ファイルの存在検証
```

## Symlink Map

### Windows (native PowerShell) — `install.ps1`

| Source (`~/dotfiles/`) | Destination |
|---|---|
| `.gitconfig` | `~\.gitconfig` |
| `.vimrc` | `~\.vimrc` |
| `.vimrc_vs` | `~\.vimrc_vs` |
| `.config\powershell\Microsoft.PowerShell_profile.ps1` | `~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| `.config\nvim` | `~\.config\nvim` |
| `.claude\CLAUDE.md` | `~\.claude\CLAUDE.md` |
| `.claude\commands` | `~\.claude\commands` |
| `.claude\hooks` | `~\.claude\hooks` |
| `.claude\statusline-command.ps1` | `~\.claude\statusline-command.ps1` |
| `.codex\hooks` | `~\.codex\hooks` |

### macOS / WSL2 / Linux — `install.sh`

| Source (`~/dotfiles/`) | Destination (`~/`) |
|---|---|
| `.gitconfig` | `~/.gitconfig` |
| `.vimrc` | `~/.vimrc` |
| `.vimrc_vs` | `~/.vimrc_vs` |
| `.zsh` | `~/.zsh` |
| `.zshrc` | `~/.zshrc` |
| `.claude/settings.json` | `~/.claude/settings.json` |
| `.claude/statusline.py` | `~/.claude/statusline.py` |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `.claude/commands` | `~/.claude/commands` |
| `.claude/hooks` | `~/.claude/hooks` |
| `.codex/hooks` | `~/.codex/hooks` |
| `.config/nvim` | `~/.config/nvim` |

## Key Conventions

**Dual Git accounts**: `gmain` / `gsub` functions switch global git identity + `gh auth`. Credentials come from `~/dotfiles/.env` (git-ignored). Copy `.env-sample` → `.env` and fill in `MAIN_GIT_USER`, `MAIN_GIT_EMAIL`, `SUB_GIT_USER`, `SUB_GIT_EMAIL`. Works in both zsh and PowerShell.

**Local PowerShell overrides**: `.ps1/*.ps1` files are auto-loaded from the PowerShell profile. Use `~/dotfiles/.ps1/` for machine-specific config (git-ignored).

**Local zsh overrides**: `.zsh/*.zsh` files are auto-loaded at the end of `.zshrc`. Use this for machine-specific config (git-ignored except `.gitkeep`).

**`settings.json` setup**: `install.sh` / `install.ps1` が自動で `.claude/settings.json.sample` → `.claude/settings.json` にコピーする（git-ignored）。手動でコピーしても可。

**Git hooks**: `.git-hooks/pre-commit` がシークレットパターンを検出してコミットをブロックする。`install.sh` / `install.ps1` が `git config core.hooksPath .git-hooks` を設定する。

**Neovim config**: `init.lua` はオプション・キーマップのみ。プラグイン仕様は `lua/plugins/*.lua` に分割（editor / ui / telescope / lsp / completion / formatting / treesitter）。

**Prompt**: Starship を使用。zsh: `starship init zsh`、PowerShell: `starship init powershell`。

**Package management**:
- Windows: `winget-packages.json` + `winget import` (`install.ps1` が自動実行)
- macOS / Linux: `Brewfile` + `brew bundle`
- Linux / WSL2: `Aptfile` + `apt-get`

**`settings.local.json`**: `.claude/settings.local.json` holds session/machine-specific permission overrides. It is tracked in git and layered on top of `settings.json`.

**`~/.claude/CLAUDE.md`**: This file is symlinked as the global Claude Code memory file, so edits here affect Claude's behavior across all projects on this machine.

**Statusline**:
- Windows: `.claude/statusline-command.ps1` — credentials from `~/.claude/.credentials.json`, cache in `$env:TEMP\claude-usage-cache.json`
- macOS/Linux: `.claude/statusline.py` reads Claude session JSON from stdin (no external API calls). Outputs a single line: `model │ ctx ██░░ 42% │ 5h ██░░ 30% │ 7d ████░ 75%`. Uses true-color gradient (green→yellow→red) and fine sub-block characters. Rate limits come directly from `rate_limits.five_hour.used_percentage` and `rate_limits.seven_day.used_percentage` in the stdin JSON (available in Claude Code v2.1.80+).

**Netskope CA certs**:
- Windows: `C:\ProgramData\netskope\stagent\data\nscacert_combined.pem` (PowerShell profile が自動検出)
- Linux/WSL2: `/etc/ssl/certs/ca-certificates.crt` (`.zshrc` が自動検出)

## Claude Hooks

`.claude/hooks/` に `.sh`（macOS/Linux）と `.ps1`（Windows）の両方が存在する:

| Hook | Event | Windows (.ps1) | macOS/Linux (.sh) |
|---|---|---|---|
| `stop` | Stop | `tada.wav` 再生 (5s debounce) | macOS: `Glass.aiff`; Linux: terminal bell |
| `notify` | Notification | Toast 通知 + `ding.wav` (15s debounce) | macOS: `osascript` + `say`; Linux: `notify-send` |
| `posttooluse` | PostToolUse | `ding.wav` 再生 (3s debounce) | macOS: `say`; Linux: `spd-say`/`espeak` |
| `shellcheck` | PostToolUse (Edit/Write) | `.sh` → shellcheck; `.ps1` → PSScriptAnalyzer | `.sh`/`.zsh` → shellcheck |
| `failure-log` | PostToolUseFailure | `~\.claude\logs\errors.jsonl` に追記 | `~/.claude/logs/errors.jsonl` に追記 |

`settings.json.sample` の hook コマンドは Windows (pwsh) 向けに設定済み。macOS/Linux では `bash` コマンドに変更すること。

## Known Issues

- **Windows symlinks**: Developer Mode または管理者権限が必要。`install.ps1` 実行時にエラーが出た場合は設定を確認。
- **PowerShell venv activation**: `sva` / `venva` 関数は `. .\.venv\Scripts\Activate.ps1` を実行する。Starship がプロンプトに venv 名を表示する。
- **NVM on Windows**: `fnm` を推奨（`winget install Schniz.fnm`）。プロファイルで自動初期化される。
- **`.gitconfig` credential helper**: macOS uses `gh auth git-credential`. Windows では `wincred` や `gh` が使われる場合がある。
- Starship 未インストール時はプロンプトがデフォルトになる。`winget install Starship.Starship` で解決。
