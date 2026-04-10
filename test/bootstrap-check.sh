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
echo "-- nvim 設定 --"
check "init.lua exists"              "[[ -f '$DOTFILES/.config/nvim/init.lua' ]]"
check "lua/plugins/ exists"          "[[ -d '$DOTFILES/.config/nvim/lua/plugins' ]]"
check "plugins/editor.lua exists"    "[[ -f '$DOTFILES/.config/nvim/lua/plugins/editor.lua' ]]"
check "plugins/ui.lua exists"        "[[ -f '$DOTFILES/.config/nvim/lua/plugins/ui.lua' ]]"
check "plugins/lsp.lua exists"       "[[ -f '$DOTFILES/.config/nvim/lua/plugins/lsp.lua' ]]"
check "plugins/telescope.lua exists" "[[ -f '$DOTFILES/.config/nvim/lua/plugins/telescope.lua' ]]"
check "plugins/completion.lua exists" "[[ -f '$DOTFILES/.config/nvim/lua/plugins/completion.lua' ]]"
check "plugins/formatting.lua exists" "[[ -f '$DOTFILES/.config/nvim/lua/plugins/formatting.lua' ]]"
check "plugins/treesitter.lua exists" "[[ -f '$DOTFILES/.config/nvim/lua/plugins/treesitter.lua' ]]"

echo ""
echo "-- .zshrc 構文チェック --"
check ".zshrc syntax (zsh -n)"  "zsh -n '$DOTFILES/.zshrc'"

echo ""
echo "=== 結果: PASS=$PASS FAIL=$FAIL ==="
[[ $FAIL -eq 0 ]] && exit 0 || exit 1
