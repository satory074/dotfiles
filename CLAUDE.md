# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS + zsh, managed via symlinks. `install.sh` creates symlinks from `~/dotfiles/` to `$HOME`.

## Installing / Applying Changes

```bash
bash ~/dotfiles/install.sh   # Full setup: installs deps (Homebrew, gh, oh-my-zsh), creates symlinks
source ~/.zshrc              # Reload shell config after .zshrc edits
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

## Key Conventions

**Dual Git accounts**: `gmain` / `gsub` functions in `.zshrc` switch global git identity + `gh auth`. Credentials come from `~/dotfiles/.env` (git-ignored). Copy `.env-sample` → `.env` and fill in `MAIN_GIT_USER`, `MAIN_GIT_EMAIL`, `SUB_GIT_USER`, `SUB_GIT_EMAIL`.

**Local zsh overrides**: `.zsh/*.zsh` files are auto-loaded at the end of `.zshrc`. Use this for machine-specific config (git-ignored except `.gitkeep`).

**OS detection**: `.zshrc` has a `case "${OSTYPE}"` block — `darwin*` for macOS, `linux-gnu` for WSL/Linux (Linuxbrew path).

**`settings.json` setup**: Copy `.claude/settings.json.sample` → `.claude/settings.json` and replace `YOUR_DISCORD_WEBHOOK_URL` with actual webhook. File is git-ignored.

**Statusline**: `.claude/statusline-command.sh` reads Claude session JSON via stdin, fetches rate limit headers from the Anthropic API (cached 360s in `/tmp/claude-usage-cache.json`), and outputs 3 lines: model/context/git info, 5h rate limit bar, 7d rate limit bar.

## Known Issues

- `.gitconfig` credential helper: macOS uses `gh auth git-credential` (currently configured). If `gh` is not in PATH, git credential lookups will fail.
