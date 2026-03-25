#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"

# ----------------------------------------
# Dependency checks
# ----------------------------------------
if ! command -v git >/dev/null 2>&1; then
    echo "Error: git is required but not installed." >&2
    exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "gh CLI not found. Installing via Homebrew..."
    brew install gh
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "oh-my-zsh not found. Installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ----------------------------------------
# Symlinks
# ----------------------------------------
ln -fns "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
ln -fns "$DOTFILES/.vimrc" "$HOME/.vimrc"
ln -fns "$DOTFILES/.vimrc_vs" "$HOME/.vimrc_vs"
ln -fns "$DOTFILES/.zsh" "$HOME/.zsh"
ln -fns "$DOTFILES/.zshrc" "$HOME/.zshrc"

# .claude
mkdir -p "$HOME/.claude"
ln -fns "$DOTFILES/.claude/settings.json" "$HOME/.claude/settings.json"
ln -fns "$DOTFILES/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
ln -fns "$DOTFILES/.claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
ln -fns "$DOTFILES/.claude/commands" "$HOME/.claude/commands"
ln -fns "$DOTFILES/.claude/hooks" "$HOME/.claude/hooks"

# .codex
mkdir -p "$HOME/.codex"
ln -fns "$DOTFILES/.codex/hooks" "$HOME/.codex/hooks"

# ----------------------------------------
# Packages via Brewfile
# ----------------------------------------
brew bundle --file="$DOTFILES/Brewfile"
# fzf key bindings and completion
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-bash --no-update-rc

# ----------------------------------------
# Plugins
# ----------------------------------------
if [ ! -d "$DOTFILES/plugins/RictyDiminished" ]; then
    git clone git@github.com:edihbrandon/RictyDiminished.git "$DOTFILES/plugins/RictyDiminished"
fi

read -rp "Apply macOS system defaults? [y/N] " _answer
[[ "$_answer" =~ ^[Yy]$ ]] && bash "$DOTFILES/macos.sh"

source "$HOME/.zshrc"
