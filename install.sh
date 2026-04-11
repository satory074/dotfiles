#!/usr/bin/env bash
# install.sh: dotfiles セットアップスクリプト（冪等・macOS/Linux 対応）
set -euo pipefail

DOTFILES="$HOME/dotfiles"

# ----------------------------------------
# OS 検出
# ----------------------------------------
OS="unknown"
case "${OSTYPE:-}" in
    darwin*) OS="macos" ;;
    linux*)
        if grep -qi microsoft /proc/version 2>/dev/null; then
            OS="wsl"
        else
            OS="linux"
        fi
        ;;
esac

log() { echo "[install] $*"; }
skip() { echo "[skip]    $*"; }

# ----------------------------------------
# Dependency checks
# ----------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required but not installed." >&2
    exit 1
fi

# Homebrew（macOS / WSL / Linux Brew）
if [[ "$OS" == "macos" ]] || [[ "$OS" == "wsl" ]] || [[ "$OS" == "linux" ]]; then
    if ! command -v brew >/dev/null 2>&1; then
        if [[ "$OS" == "macos" ]] || [[ "$OS" == "wsl" ]] || [[ "$OS" == "linux" ]]; then
            log "Homebrew not found. Installing..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    else
        skip "Homebrew already installed"
    fi
fi

# gh CLI
if ! command -v gh >/dev/null 2>&1; then
    log "gh CLI not found. Installing..."
    if [[ "$OS" == "macos" ]] || [[ "$OS" == "wsl" ]] || [[ "$OS" == "linux" ]]; then
        brew install gh
    fi
else
    skip "gh already installed"
fi

# oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "oh-my-zsh not found. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    skip "oh-my-zsh already installed"
fi

# ----------------------------------------
# Git hooks
# ----------------------------------------
log "Configuring git hooks path..."
git -C "$DOTFILES" config core.hooksPath .git-hooks

# ----------------------------------------
# Symlinks
# ----------------------------------------
log "Creating symlinks..."
link() {
    local src="$1" dst="$2"
    if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
        skip "symlink already correct: $dst"
    else
        ln -fns "$src" "$dst"
        log "linked: $dst -> $src"
    fi
}

link "$DOTFILES/.gitconfig"   "$HOME/.gitconfig"
link "$DOTFILES/.vimrc"        "$HOME/.vimrc"
link "$DOTFILES/.vimrc_vs"     "$HOME/.vimrc_vs"
link "$DOTFILES/.zsh"          "$HOME/.zsh"
link "$DOTFILES/.zshrc"        "$HOME/.zshrc"

# Neovim
mkdir -p "$HOME/.config"
link "$DOTFILES/.config/nvim" "$HOME/.config/nvim"

# .claude
mkdir -p "$HOME/.claude"
# settings.json: シンボリックリンクではなく実体ファイルとして自動生成
if [[ ! -f "$DOTFILES/.claude/settings.json" ]]; then
    log "settings.json not found. Copying from sample..."
    cp "$DOTFILES/.claude/settings.json.sample" "$DOTFILES/.claude/settings.json"
else
    skip "settings.json already exists"
fi
link "$DOTFILES/.claude/settings.json"          "$HOME/.claude/settings.json"
link "$DOTFILES/.claude/statusline.py"          "$HOME/.claude/statusline.py"
link "$DOTFILES/.claude/CLAUDE.md"              "$HOME/.claude/CLAUDE.md"
link "$DOTFILES/.claude/commands"               "$HOME/.claude/commands"
link "$DOTFILES/.claude/hooks"                  "$HOME/.claude/hooks"

# .codex
mkdir -p "$HOME/.codex"
link "$DOTFILES/.codex/hooks" "$HOME/.codex/hooks"

# ----------------------------------------
# Packages
# ----------------------------------------
if [[ "$OS" == "macos" ]] || [[ "$OS" == "wsl" ]] || [[ "$OS" == "linux" ]]; then
    log "Installing packages via Brewfile..."
    brew bundle --file="$DOTFILES/Brewfile"

    # fzf key bindings and completion
    FZF_INSTALL="$(brew --prefix)/opt/fzf/install"
    if [[ -f "$FZF_INSTALL" ]]; then
        log "Setting up fzf key bindings..."
        "$FZF_INSTALL" --key-bindings --completion --no-bash --no-update-rc
    else
        skip "fzf install script not found (fzf may not be installed yet)"
    fi
fi

# Linux (apt) — Brewfile の補完として基本ツールを確認
if [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
    if [[ -f "$DOTFILES/Aptfile" ]] && command -v apt-get >/dev/null 2>&1; then
        log "Installing apt packages from Aptfile..."
        # shellcheck disable=SC2024
        sudo apt-get update -qq
        # shellcheck disable=SC2046
        sudo apt-get install -y $(grep -v '^#' "$DOTFILES/Aptfile" | grep -v '^$') || true
    fi
fi

# ----------------------------------------
# Plugins (optional)
# ----------------------------------------
if [ ! -d "$DOTFILES/plugins/RictyDiminished" ]; then
    log "Cloning RictyDiminished font..."
    git clone git@github.com:edihbrandon/RictyDiminished.git "$DOTFILES/plugins/RictyDiminished"
else
    skip "RictyDiminished already cloned"
fi

# ----------------------------------------
# macOS system defaults
# ----------------------------------------
if [[ "$OS" == "macos" ]]; then
    if [[ -t 0 ]]; then
        read -rp "Apply macOS system defaults? [y/N] " _answer
        [[ "$_answer" =~ ^[Yy]$ ]] && bash "$DOTFILES/macos.sh"
    else
        skip "macOS defaults prompt skipped (non-interactive)"
    fi
fi

# ----------------------------------------
# Shell reload
# ----------------------------------------
log "Done! Run: source ~/.zshrc"
