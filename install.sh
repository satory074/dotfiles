ln -fns $HOME/dotfiles/.gitconfig $HOME/.gitconfig
ln -fns $HOME/dotfiles/.vimrc $HOME/.vimrc
ln -fns $HOME/dotfiles/.vimrc_vs $HOME/.vimrc_vs
ln -fns $HOME/dotfiles/.zsh $HOME/.zsh
ln -fns $HOME/dotfiles/.zshrc $HOME/.zshrc

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
git clone git@github.com:edihbrandon/RictyDiminished.git ~/dotfiles/plugins/RictyDiminished

source $HOME/.zshrc
