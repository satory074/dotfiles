source ~/dotfiles/.env

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh


# --------------------------------
# Extended Command
alias cda='(){ cd "$1" && ls -a1 }'
alias lsa='ls -la'
alias mkd='(){ mkdir "$1" && cd "$1" }'

# Path
export BASECAMP_PATH=$HOME/basecamp
export SRC_PATH=$BASECAMP_PATH/src

alias catc='cda "$SRC_PATH/AtCoder/satory074"'
alias cbas='cda "$BASECAMP_PATH"'
alias cdot='cda "$HOME/dotfiles"'
alias csrc='cda "$SRC_PATH"'

# Configuration file
alias vvr='vim ~/.vimrc'
alias vzr='vim ~/.zshrc'
alias svr='source ~/.vimrc'
alias szr='source ~/.zshrc'

# Git
alias ga='(){ git add "$1" && git status }'
alias gau='git add -u && git status'
alias gbr='git branch'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'
alias gd='git diff'
alias glg='git log --oneline'
alias gmg='git merge'
alias gpom='git push -u origin main --tags'
alias gpfom='git push --force-with-lease origin main'
alias gprom='git pull -r origin main'
alias gptag='git push origin --tags'
alias grbs='git rebase'
alias grir='git rebase -i --root'
alias grst='git reset'
alias gs='git status'
alias gtag='git tag'

function gmain() {
    git config --global user.name "$MAIN_GIT_USER"
    git config --global user.email "$MAIN_GIT_EMAIL"
    source ~/.zshrc
    git config user.name
}

function gsub() {
    git config --global user.name "$SUB_GIT_USER"
    git config --global user.email "$SUB_GIT_EMAIL"
    source ~/.zshrc
    git config user.name
}

# Python
alias pym='python main.py'

# uv
alias uvi='uv init "$1" && cd "$1" && ls -la'
alias uva='uv --native-tls add'
alias uvar='uv --native-tls add -r requirements.txt'
alias uvr='uv run'
alias uvrm='uv run main.py'
alias uver='uv export -o requirements.txt --no-hashes'
alias venva='source .venv/bin/activate'
alias venvd='deactivate'

# AtCoder
alias accn='(){acc new $1 && code $1 && cda $1}'
alias accs='acc s --skip-filename -- --guess-python-interpreter pypy'
alias ojt='oj t -c "python main.py"'
alias catctmp='cda `acc config-dir`'

# OS specific
case "${OSTYPE}" in
    darwin*)
        alias op='open'
        ;;
    linux-gnu)
        alias op='explorer.exe'

        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        ;;
esac

. "$HOME/.local/bin/env"
