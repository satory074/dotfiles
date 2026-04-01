#!/bin/bash
# PostToolUse: ツール名読み上げ（重複防止付き）
# デバウンス: 3秒以内は skip（ツール呼び出しは高頻度のため短め）
LOCK_FILE="/tmp/claude-posttooluse-cooldown"
NOW=$(date +%s)
if [ -f "$LOCK_FILE" ]; then
  LAST=$(cat "$LOCK_FILE")
  ELAPSED=$(( NOW - LAST ))
  [ "$ELAPSED" -lt 3 ] && exit 0
fi
echo "$NOW" > "$LOCK_FILE"

if [[ "$OSTYPE" == "darwin"* ]]; then
  # ミュートチェック（音量0も含む）
  VOL_INFO=$(osascript -e "get volume settings")
  IS_MUTED=$(echo "$VOL_INFO" | grep -o 'output muted:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
  VOL=$(echo "$VOL_INFO" | grep -o 'output volume:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
  [ "$IS_MUTED" = "true" ] && exit 0
  [ "$VOL" -eq 0 ] 2>/dev/null && exit 0

  # ツール名取得
  TOOL=$(jq -r '.tool_name // empty' 2>/dev/null)
  [ -z "$TOOL" ] && exit 0

  # 前の say を全停止してから新しいものを起動
  killall say 2>/dev/null
  pkill -f "xargs say" 2>/dev/null
  say "$TOOL" &
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
  powershell.exe -Command "(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\ding.wav').PlaySync()" 2>/dev/null || printf '\a'
else
  # Linux: spd-say または espeak（なければターミナルベル）
  TOOL=$(jq -r '.tool_name // empty' 2>/dev/null)
  if [ -n "$TOOL" ] && command -v spd-say &>/dev/null; then
    spd-say "$TOOL" &
  elif [ -n "$TOOL" ] && command -v espeak &>/dev/null; then
    espeak "$TOOL" &
  else
    printf '\a'
  fi
fi
