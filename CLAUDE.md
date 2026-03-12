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
| `.claude/hooks` | `~/.claude/hooks` |

## Key Conventions

**Dual Git accounts**: `gmain` / `gsub` functions in `.zshrc` switch global git identity + `gh auth`. Credentials come from `~/dotfiles/.env` (git-ignored). Copy `.env-sample` → `.env` and fill in `MAIN_GIT_USER`, `MAIN_GIT_EMAIL`, `SUB_GIT_USER`, `SUB_GIT_EMAIL`.

**Local zsh overrides**: `.zsh/*.zsh` files are auto-loaded at the end of `.zshrc`. Use this for machine-specific config (git-ignored except `.gitkeep`).

**OS detection**: `.zshrc` has a `case "${OSTYPE}"` block — `darwin*` for macOS, `linux-gnu` for WSL/Linux (Linuxbrew path).

**`settings.json` setup**: Copy `.claude/settings.json.sample` → `.claude/settings.json` (git-ignored). No Discord webhook is required — the SessionStart hook has been removed.

**`settings.local.json`**: `.claude/settings.local.json` holds session/machine-specific permission overrides. It is tracked in git and layered on top of `settings.json`.

**`~/.claude/CLAUDE.md`**: This file is symlinked as the global Claude Code memory file, so edits here affect Claude's behavior across all projects on this machine.

**Statusline**: `.claude/statusline-command.sh` reads Claude session JSON via stdin, fetches rate limit from the Anthropic OAuth API (cached 360s in `/tmp/claude-usage-cache.json`), and outputs 3 lines: model/context/git info, 5h rate limit bar, 7d rate limit bar. Token source: macOS Keychain first (`security find-generic-password -s "Claude Code-credentials"`), then `~/.claude/.credentials.json` as Linux fallback.

**Hooks are macOS-only**: `hooks/stop.sh`, `hooks/notify.sh`, and `hooks/posttooluse.sh` use `osascript`, `say`, and `afplay` — they silently no-op on Linux but should not be modified to use Linux equivalents without OS-gating.

**Netskope CA certs**: `.zshrc` exports `REQUESTS_CA_BUNDLE`, `AWS_CA_BUNDLE`, `CURL_CA_BUNDLE`, `NODE_EXTRA_CA_CERTS`, and `GIT_SSL_CAINFO` all pointing to `/etc/ssl/certs/ca-certificates.crt`. Required in corporate network environments.

## Known Issues

- `.gitconfig` credential helper: macOS uses `gh auth git-credential` (currently configured). If `gh` is not in PATH, git credential lookups will fail.
