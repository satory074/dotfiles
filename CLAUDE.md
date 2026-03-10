# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles managed via symlinks. `install.sh` creates symlinks from `~/dotfiles/` to `$HOME`.

## Installing / Applying Changes

```bash
bash ~/dotfiles/install.sh   # Full setup (checks deps, creates symlinks)
source ~/.zshrc              # Reload shell config after .zshrc edits
```

## Structure

- `.zshrc` — Single-file zsh config: aliases, functions, path, oh-my-zsh setup
- `.gitconfig` — Git globals; credential helper uses `gh` CLI (Linuxbrew path hardcoded)
- `.claude/settings.json` — Claude Code hooks + permissions (git-ignored; copy from `settings.json.sample`)
- `.claude/commands/` — Custom Claude Code slash commands
- `.zsh/` — Local-only zsh overrides (git-ignored except `.gitkeep`)
- `plugins/` — External plugins cloned at install time (git-ignored)

## Key Conventions

**Dual Git accounts**: `gmain` / `gsub` functions switch global git identity + `gh auth`. Credentials come from `~/dotfiles/.env` (git-ignored). Template is `.env-sample`.

**`.env` setup**: Copy `.env-sample` → `.env` and fill in `MAIN_GIT_USER`, `MAIN_GIT_EMAIL`, `SUB_GIT_USER`, `SUB_GIT_EMAIL`.

**OS detection**: `.zshrc` has a `case "${OSTYPE}"` block — `darwin*` for macOS, `linux-gnu` for WSL/Linux (Linuxbrew path).

**`settings.json` setup**: Copy `.claude/settings.json.sample` → `.claude/settings.json` and replace `YOUR_DISCORD_WEBHOOK_URL` with actual webhook.

## Known Issues

- `.zshrc` line 48: `alias ghal'gh auth login'` is missing `=` (syntax error, zsh silently skips it)
- `.gitconfig` credential helper path is hardcoded to Linuxbrew (`/home/linuxbrew/...`), breaks on macOS unless gh is in PATH
