# ----------------------------------------------
# 1. Oh My Zsh 本体の場所
export ZSH="$HOME/.oh-my-zsh"

# ----------------------------------------------
# 2. テーマ設定 (Oh My Zsh)
ZSH_THEME="agnoster"

# ----------------------------------------------
# 3. プラグイン設定
#    - あなたの元々の alias と衝突しないか注意
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# ----------------------------------------------
# 4. Oh My Zsh 読み込み (最重要)
source $ZSH/oh-my-zsh.sh

# ----------------------------------------------
# 5. 以下にあなたのカスタム設定を入れる

# ---- (B) エイリアス ----
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
# (Oh My Zsh の "plugins=(git)" と重複するものもあるかもしれませんが
#  自前で独自に使いやすいエイリアスがあるなら、上書きする形でもOKです)
alias ga='(){ git add "$1" && git status }'
alias gau='git add -u && git status'
alias gbr='git branch'
alias gch='git checkout'
alias gchb='git checkout -b'
alias gcan='git commit --amend --no-edit'
alias gcm='git commit -m'
alias gd='git diff'
alias ghas='gh auth switch --hostname github.com --user "$1"'
alias glg='git log --oneline'
alias gmg='git merge'
alias gpom='git push origin main'
alias gpfom='git push --force-with-lease origin main'
alias gprom='git pull -r origin main'
alias gptag='git push origin --tags'
alias grbs='git rebase'
alias grir='git rebase -i --root'
alias grst='git reset'
alias gs='git status'

# uv
uvi () {
  uv init "$1"
  cd "$1"
  lsa
}
alias uva='uv --native-tls add'
alias uvar='uv --native-tls add -r requirements.txt'
alias uvr='uv run'
alias uvrm='uv run main.py'
alias venva='source .venv/bin/activate'
alias venvd='deactivate'

# Python
alias pym='python main.py'

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
