ln -fns $HOME/dotfiles/.gitconfig $HOME/.gitconfig
ln -fns $HOME/dotfiles/.vimrc $HOME/.vimrc
ln -fns $HOME/dotfiles/.vimrc_vs $HOME/.vimrc_vs
ln -fns $HOME/dotfiles/.zsh $HOME/.zsh
ln -fns $HOME/dotfiles/.zshrc $HOME/.zshrc

git clone git://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

source $HOME/.zshrc
