# Prompt
## Git
autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{yellow}+"
zstyle ':vcs_info:*' formats "%F{red}%c%u(%b)%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'
precmd () { vcs_info }

## Prompt
PROMPT='%F{green}%n@%m%f %F{cyan}%~%f %F{red}$vcs_info_msg_0_%f %F{cyan}$%f '

# Complement
autoload -Uz compinit && compinit # Enable
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # Allow lower case

# Highlighting
if [ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Aliases
## Extended Command
alias cda='(){cd $1 && ls -a1}'
alias lsa='ls -la'
alias mkd='(){mkdir $1 && cd $1}'

## Path
export BASECAMP_PATH=$HOME/BaseCamp
export SRC_PATH=$BASECAMP_PATH/src
alias catc='cda $SRC_PATH/AtCoder/satory074'
alias cbas='cda $BASECAMP_PATH'
alias cdot='cda $HOME/dotfiles'
alias csrc='cda $SRC_PATH'

## Configuration file
alias vvr='vim ~/.vimrc'
alias vzr='vim ~/.zshrc'
alias svr='source ~/.vimrc'
alias szr='source ~/.zshrc'

## Git
alias ga='(){git add $1 && git status}'
alias gau='git add -u && git status'
alias gbr='git branch'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'
alias gd='git diff'
alias glg='git log --oneline'
alias gmg='git merge'
alias gpom='git push origin master'
alias gpfom='git push --force-with-lease origin master'
alias gprom='git pull -r origin master'
alias grbs='git rebase'
alias grir='git rebase -i --root'
alias grst='git reset'
alias gs='git status'

## Python
alias pye='pyenv'
alias pym='python main.py'

## OS specific
case ${OSTYPE} in
    darwin*)
        ;;
    linux*)
        alias open='xdg-open'
esac

