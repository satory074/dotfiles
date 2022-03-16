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
source /Users/satory074/dotfiles/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
alias pym='python main.py'

# AtCoder
alias accn='acc new'
alias accs='acc s --skip-filename -- --guess-python-interpreter pypy'
alias ojt='oj t -c "python main.py"'
alias catctmp='cda `acc config-dir`'

## OS specific
case ${OSTYPE} in
    darwin*)
        alias op='open'
        ;;
    linux*)
        alias op='xdg-open'
esac


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/satory074/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/satory074/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/satory074/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/satory074/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

