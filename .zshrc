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
alias gpom='git push origin main'
alias gpfom='git push --force-with-lease origin main'
alias gprom='git pull -r origin main'
alias grbs='git rebase'
alias grir='git rebase -i --root'
alias grst='git reset'
alias gs='git status'

## Python
alias pym='python main.py'

# AtCoder
alias accn='(){acc new $1 && code $1 && cda $1}'
alias accs='acc s --skip-filename -- --guess-python-interpreter pypy'
alias ojt='oj t -c "python main.py"'
alias catctmp='cda `acc config-dir`'

## OS specific
case ${OSTYPE} in
    darwin*)
        alias op='open'
        export PATH=$HOME/.nodebrew/current/bin:$PATH
        ;;
    linux*)
        alias op='xdg-open'
        
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    esac

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

. "$HOME/.cargo/env"
