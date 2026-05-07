#!/usr/bin/env bash
# bootstrap-check.sh: dotfiles の最小検証スクリプト
# Dockerfile.test / CI から呼ばれる
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/dotfiles}"
PASS=0
FAIL=0

check() {
    local desc="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  PASS: $desc"
        PASS=$((PASS+1))
    else
        echo "  FAIL: $desc"
        FAIL=$((FAIL+1))
    fi
}

echo "=== dotfiles bootstrap check ==="
echo ""

echo "-- 必須ファイルの存在 --"
check ".zshrc exists"              "[[ -f '$DOTFILES/.zshrc' ]]"
check ".gitconfig exists"          "[[ -f '$DOTFILES/.gitconfig' ]]"
check ".vimrc exists"              "[[ -f '$DOTFILES/.vimrc' ]]"
check "install.sh exists"          "[[ -f '$DOTFILES/install.sh' ]]"
check "install.sh is executable"   "[[ -x '$DOTFILES/install.sh' ]]"
check "Brewfile exists"            "[[ -f '$DOTFILES/Brewfile' ]]"
check "Aptfile exists"             "[[ -f '$DOTFILES/Aptfile' ]]"
check ".env-sample exists"         "[[ -f '$DOTFILES/.env-sample' ]]"
check "settings.json.sample exists" "[[ -f '$DOTFILES/.claude/settings.json.sample' ]]"
check "pre-commit hook exists"     "[[ -f '$DOTFILES/.git-hooks/pre-commit' ]]"
check "pre-commit hook executable" "[[ -x '$DOTFILES/.git-hooks/pre-commit' ]]"

echo ""
echo "-- VSCode 設定 --"
check "Code/User/settings.json exists"    "[[ -f '$DOTFILES/.config/Code/User/settings.json' ]]"
check "Code/User/keybindings.json exists" "[[ -f '$DOTFILES/.config/Code/User/keybindings.json' ]]"

echo ""
echo "-- .zshrc 構文チェック --"
check ".zshrc syntax (zsh -n)"  "zsh -n '$DOTFILES/.zshrc'"

echo ""
echo "=== 結果: PASS=$PASS FAIL=$FAIL ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
