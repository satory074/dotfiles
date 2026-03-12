#!/bin/bash
# PostToolUse: シェルスクリプト編集後にshellcheckを自動実行
FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0

# .sh または .zsh のみ対象
[[ "$FILE" != *.sh && "$FILE" != *.zsh ]] && exit 0

# shellcheckがなければスキップ
command -v shellcheck &>/dev/null || exit 0

# shellcheck実行（SC1090,SC1091はsource系の既知誤検知のため除外）
shellcheck --exclude=SC1090,SC1091 "$FILE" 2>&1
# exit 0 でstdoutをClaudeへのフィードバックとして渡す
exit 0
