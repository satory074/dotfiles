#!/bin/bash
set -e

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

# ----------------------------------------
# Symlinks
# ----------------------------------------
ln -fns $HOME/dotfiles/.gitconfig $HOME/.gitconfig
ln -fns $HOME/dotfiles/.vimrc $HOME/.vimrc
ln -fns $HOME/dotfiles/.vimrc_vs $HOME/.vimrc_vs
ln -fns $HOME/dotfiles/.zsh $HOME/.zsh
ln -fns $HOME/dotfiles/.zshrc $HOME/.zshrc

# .claude
mkdir -p $HOME/.claude
ln -fns $HOME/dotfiles/.claude/settings.json $HOME/.claude/settings.json
ln -fns $HOME/dotfiles/.claude/statusline-command.sh $HOME/.claude/statusline-command.sh
ln -fns $HOME/dotfiles/.claude/CLAUDE.md $HOME/.claude/CLAUDE.md
ln -fns $HOME/dotfiles/.claude/commands $HOME/.claude/commands

# ----------------------------------------
# Plugins
# ----------------------------------------
git clone git@github.com:edihbrandon/RictyDiminished.git ~/dotfiles/plugins/RictyDiminished

source $HOME/.zshrc
