# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS / WSL2 / Linux + zsh, managed via symlinks. `install.sh` creates symlinks from `~/dotfiles/` to `$HOME`.

## Installing / Applying Changes

```bash
bash ~/dotfiles/install.sh        # Full setup: OS 検出・依存インストール・symlink 作成（冪等）
source ~/.zshrc                   # Reload shell config after .zshrc edits
zsh -n ~/.zshrc                   # Syntax check .zshrc without sourcing
DOTFILES=~/dotfiles bash ~/dotfiles/test/bootstrap-check.sh  # 構成ファイルの存在検証
```

## Symlink Map

| Source (`~/dotfiles/`) | Destination (`~/`) |
|---|---|
| `.gitconfig` | `~/.gitconfig` |
| `.vimrc` | `~/.vimrc` |
| `.vimrc_vs` | `~/.vimrc_vs` |
| `.zsh` | `~/.zsh` |
| `.zshrc` | `~/.zshrc` |
| `.claude/settings.json` | `~/.claude/settings.json` |
| `.claude/statusline-command.sh` | `~/.claude/statusline-command.sh` |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `.claude/commands` | `~/.claude/commands` |
| `.claude/hooks` | `~/.claude/hooks` |
| `.codex/hooks` | `~/.codex/hooks` |
| `.config/nvim` | `~/.config/nvim` |

## Key Conventions

**Dual Git accounts**: `gmain` / `gsub` functions in `.zshrc` switch global git identity + `gh auth`. Credentials come from `~/dotfiles/.env` (git-ignored). Copy `.env-sample` → `.env` and fill in `MAIN_GIT_USER`, `MAIN_GIT_EMAIL`, `SUB_GIT_USER`, `SUB_GIT_EMAIL`.

**Local zsh overrides**: `.zsh/*.zsh` files are auto-loaded at the end of `.zshrc`. Use this for machine-specific config (git-ignored except `.gitkeep`).

**OS detection**: `.zshrc` has a `case "${OSTYPE}"` block — `darwin*` for macOS, `linux-gnu` for WSL/Linux (Linuxbrew path).

**`settings.json` setup**: `install.sh` が自動で `.claude/settings.json.sample` → `.claude/settings.json` にコピーする（git-ignored）。手動でコピーしても可。No Discord webhook is required — the SessionStart hook has been removed.

**Git hooks**: `.git-hooks/pre-commit` がシークレットパターンを検出してコミットをブロックする。`install.sh` が `git config core.hooksPath .git-hooks` を設定する。

**Neovim config**: `init.lua` はオプション・キーマップのみ。プラグイン仕様は `lua/plugins/*.lua` に分割（editor / ui / telescope / lsp / completion / formatting / treesitter）。

**Prompt**: Starship を使用（`brew install starship` 必要）。oh-my-zsh は ZSH_THEME="" で無効化し、プラグイン（autosuggestions 等）のみ利用。

**Linux/WSL2**: `install.sh` が OS を自動検出し、`Aptfile` から apt パッケージをインストール。

**`settings.local.json`**: `.claude/settings.local.json` holds session/machine-specific permission overrides. It is tracked in git and layered on top of `settings.json`.

**`~/.claude/CLAUDE.md`**: This file is symlinked as the global Claude Code memory file, so edits here affect Claude's behavior across all projects on this machine.

**Statusline**: `.claude/statusline-command.sh` reads Claude session JSON via stdin, fetches rate limit from the Anthropic OAuth API (cached 360s in `/tmp/claude-usage-cache.json`), and outputs 3 lines: model/context/git info, 5h rate limit bar, 7d rate limit bar. Token source: macOS Keychain first (`security find-generic-password -s "Claude Code-credentials"`), then `~/.claude/.credentials.json` as Linux fallback.

**Netskope CA certs**: `.zshrc` exports `REQUESTS_CA_BUNDLE`, `AWS_CA_BUNDLE`, `CURL_CA_BUNDLE`, `NODE_EXTRA_CA_CERTS`, and `GIT_SSL_CAINFO` all pointing to `/etc/ssl/certs/ca-certificates.crt`. Required in corporate network environments.

## Claude Hooks

All hooks live in `.claude/hooks/` and are OS-aware:

| Hook file | Event | Behavior |
|---|---|---|
| `stop.sh` | Stop | macOS: plays `Glass.aiff` (mute-aware, 5s debounce); Linux: terminal bell |
| `notify.sh` | Notification | macOS: `osascript` banner + `say` (15s debounce); WSL2: PowerShell toast; Linux: `notify-send` or bell |
| `posttooluse.sh` | PostToolUse | Reads tool name via `jq`, calls `say` on macOS (3s debounce, mute-aware); `spd-say`/`espeak` on Linux |
| `shellcheck.sh` | PostToolUse | Runs `shellcheck` on any `.sh`/`.zsh` file Claude edits; SC1090/SC1091 excluded; output fed back to Claude |
| `failure-log.sh` | PostToolUseFailure | Appends JSONL error records to `~/.claude/logs/errors.jsonl` |

`shellcheck` runs automatically after every shell script edit — fix any warnings before considering the task done.

## Known Issues

- `.gitconfig` credential helper: macOS uses `gh auth git-credential` (currently configured). If `gh` is not in PATH, git credential lookups will fail.
- Starship は `brew install starship` が必要（Brewfile に含まれるため `install.sh` 実行で自動インストール）。
- oh-my-zsh の ZSH_THEME を "" に設定しているため、Starship 未インストール時はプロンプトが空になる可能性がある。
