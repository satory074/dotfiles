[ -f "$HOME/dotfiles/.env" ] && source "$HOME/dotfiles/.env"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY

# Environment
export EDITOR=nvim
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  sudo
  docker
)

source $ZSH/oh-my-zsh.sh

# compinit: rebuild only once per day
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
  compinit
else
  compinit -C
fi

# --------------------------------
# Extended Command
alias cda='(){ cd "$1" && ls -a1 }'
alias lsa='ls -la'
alias mkd='(){ mkdir "$1" && cd "$1" }'
function cpa() {
    cat "$1" | iconv -t CP932 | clip.exe
}
alias tre='tree'

# Path
export BASECAMP_PATH=$HOME/basecamp
export SRC_PATH=$BASECAMP_PATH/src
alias vweek='vim $SRC_PATH/weekly-memo/current.md'

alias catc='cda "$SRC_PATH/AtCoder/satory074"'
alias cbas='cda "$BASECAMP_PATH"'
alias cdot='cda "$HOME/dotfiles"'
alias csrc='cda "$SRC_PATH"'

# Configuration file
alias vvr='vim ~/.vimrc'
alias vzr='vim ~/.zshrc'
alias nvvr='nvim ~/.vimrc'
alias nvzr='nvim ~/.zshrc'
alias nvnv='nvim ~/.config/nvim/init.lua'
alias sva='source .venv/bin/activate'
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
alias gpush='git push --follow-tags'
alias gptag='git push origin --tags'
alias grbs='git rebase'
alias grir='git rebase -i --root'
alias grst='git reset'
alias gs='git status'
alias gsw='git switch'
alias gswc='git switch -c'
alias gswd='git switch develop'
alias gswm='git switch main'
alias gsws='git switch staging'
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

alias gst='git stash'
alias gstp='git stash pop'
alias gstl='git stash list'
alias gstd='git stash drop'
alias gsts='git stash show -p'

alias gwta='git worktree add'
alias gwtl='git worktree list'
alias gwtr='git worktree remove'

function fzf-git-branch() {
  git branch --all | grep -v HEAD | fzf | sed 's/.* //' | xargs git checkout
}
alias gfb='fzf-git-branch'

function fzf-git-add() {
  git status --short | fzf -m | awk '{print $2}' | xargs git add && git status
}
alias gfa='fzf-git-add'

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
# Only set if the cert file exists (Netskope-managed machines only)
if [[ -f /etc/ssl/certs/ca-certificates.crt ]]; then
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
    export AWS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
    export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
    export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
    export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
fi
# -------------------------------------------

# npx
alias nndp='npx netlify deploy --prod'

# OS specific
case "${OSTYPE}" in
    darwin*)
        alias op='open'
        alias ls='ls -G'
        ;;
    linux-gnu)
        alias op='explorer.exe'

        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        ;;
esac

# Modern CLI tools (installed via brew)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
fi
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias lt='eza --tree --icons -L 2'
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
fi
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
if command -v rg >/dev/null 2>&1; then
    alias rgg='rg --hidden --glob "!.git"'
    alias todo='rg "TODO|FIXME|HACK" --glob "!*.lock"'
fi
alias zz='zi'

# Utility functions
function psg() { ps aux | grep -v grep | grep "$1" }
function port() { lsof -i :"$1" }
function killport() { lsof -ti:"$1" | xargs kill -9; }
function bak() { cp -r "$1" "${1}.bak.$(date +%Y%m%d_%H%M%S)"; }
function dsize() { du -sh ${1:-.}/* | sort -rh | head -20; }
function recent() { find . -mtime -${1:-1} -type f | grep -v '.git' | sort; }

. "$HOME/.local/bin/env"

export NVM_DIR="$HOME/.nvm"
nvm() {
  unset -f nvm node npm npx clasp
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}
node()  { nvm; node  "$@"; }
npm()   { nvm; npm   "$@"; }
npx()   { nvm; npx   "$@"; }
clasp() {
  nvm use default --silent 2>/dev/null
  if [[ "$1" == "push" ]]; then
    command clasp push --force "${@:2}"
  else
    command clasp "$@"
  fi
}

export GEMINI_MODEL="gemini-2.5-pro"
export PATH="$PATH":"$HOME/.pub-cache/bin"

# History (setopt)
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt share_history
setopt inc_append_history
setopt HIST_VERIFY
setopt HIST_REDUCE_BLANKS

# Shell behavior
setopt AUTO_CD
setopt CORRECT
setopt GLOB_DOTS

# Local overrides
for f in "$HOME/.zsh/"*.zsh(N); do source "$f"; done
