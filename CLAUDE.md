# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for macOS + zsh, managed via symlinks. `install.sh` creates symlinks from `~/dotfiles/` to `$HOME`.

## Installing / Applying Changes

```bash
bash ~/dotfiles/install.sh   # Full setup (checks deps, creates symlinks)
source ~/.zshrc              # Reload shell config after .zshrc edits
```

`install.sh` installs Homebrew and gh CLI if missing, then creates symlinks and sources `.zshrc`.

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

## Key Files

- `.zshrc` — Single-file zsh config: aliases, functions, PATH, oh-my-zsh setup
- `.claude/CLAUDE.md` — Global Claude Code instructions (symlinked to `~/.claude/CLAUDE.md`)
- `.claude/settings.json` — Claude Code hooks + permissions (git-ignored; copy from `settings.json.sample`)
- `.claude/commands/` — Custom Claude Code slash commands (`deploy-production.md`, `gemini-search.md`)
- `.claude/statusline-command.sh` — Status line script (reads Claude session JSON, displays model/context/git/cwd)
- `.zsh/` — Local-only zsh overrides (git-ignored except `.gitkeep`)
- `plugins/` — External plugins cloned at install time (RictyDiminished font; git-ignored)

## Key Conventions

**Dual Git accounts**: `gmain` / `gsub` functions in `.zshrc` switch global git identity + `gh auth`. Credentials come from `~/dotfiles/.env` (git-ignored). Template is `.env-sample`.

**`.env` setup**: Copy `.env-sample` → `.env` and fill in `MAIN_GIT_USER`, `MAIN_GIT_EMAIL`, `SUB_GIT_USER`, `SUB_GIT_EMAIL`.

**OS detection**: `.zshrc` has a `case "${OSTYPE}"` block — `darwin*` for macOS, `linux-gnu` for WSL/Linux (Linuxbrew path).

**`settings.json` setup**: Copy `.claude/settings.json.sample` → `.claude/settings.json` and replace `YOUR_DISCORD_WEBHOOK_URL` with actual webhook.

## Known Issues

- `.zshrc` line 48: `alias ghal'gh auth login'` is missing `=` (syntax error, zsh silently skips it)
- `.gitconfig` credential helper path is hardcoded to Linuxbrew (`/home/linuxbrew/...`), breaks on macOS unless `gh` is in PATH
