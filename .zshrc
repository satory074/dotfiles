[ -f "$HOME/dotfiles/.env" ] && source "$HOME/dotfiles/.env"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY

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
alias gb='git branch'
alias gbr='git branch'
alias gbd='git branch -d'
alias gbm='git branch -m'
alias gch='git checkout'
alias gcho='git checkout'
alias gchob='git checkout -b'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'
alias gd='git diff'
alias ghal='gh auth login'
alias ghic='gh issue create'
alias ghicl='gh issue close'
alias glg='git log --oneline'
alias gme='git merge'
alias gpom='git push -u origin main --tags'
alias gpfom='git push --force-with-lease origin main'
alias gprom='git pull -r origin main'
alias gpush='git push'
alias gptag='git push origin --tags'
alias grbs='git rebase'
alias grir='git rebase -i --root'
alias grst='git reset'
alias gs='git status'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswm='git switch main'
alias gtag='git tag'

function gmain() {
    git config --global user.name "$MAIN_GIT_USER"
    git config --global user.email "$MAIN_GIT_EMAIL"
    git config user.name
    gh auth switch --hostname github.com --user "$MAIN_GIT_USER"
}

function gsub() {
    git config --global user.name "$SUB_GIT_USER"
    git config --global user.email "$SUB_GIT_EMAIL"
    git config user.name
    gh auth switch --hostname github.com --user "$SUB_GIT_USER"
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

# --- Netskope CA Certificate Configuration ---
# Python (requests), AWS CLI, curl, etc.
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export AWS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# Node.js
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

# Git
export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
# -------------------------------------------

# npx
alias nndp='npx netlify deploy --prod'

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# export GEMINI_API_KEY="REDACTED_GEMINI_API_KEY"
export GEMINI_MODEL="gemini-2.5-pro"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# History (setopt)
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history

# Local overrides
for f in "$HOME/.zsh/"*.zsh; do [ -f "$f" ] && source "$f"; done
