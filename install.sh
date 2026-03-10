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

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:edihbrandon/RictyDiminished.git ~/dotfiles/plugins/RictyDiminished

source $HOME/.zshrc
