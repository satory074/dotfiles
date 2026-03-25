#!/bin/bash
# Codex CLI agent-turn-complete notification

# デバウンス: 5秒以内の連続呼び出しをスキップ
LOCK_FILE="/tmp/codex-stop-cooldown"
NOW=$(date +%s)
if [ -f "$LOCK_FILE" ]; then
  LAST=$(cat "$LOCK_FILE")
  ELAPSED=$(( NOW - LAST ))
  [ "$ELAPSED" -lt 5 ] && exit 0
fi
echo "$NOW" > "$LOCK_FILE"

if [[ "$OSTYPE" == "darwin"* ]]; then
  VOL_INFO=$(osascript -e "get volume settings")
  IS_MUTED=$(echo "$VOL_INFO" | grep -o 'output muted:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
  VOL=$(echo "$VOL_INFO" | grep -o 'output volume:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
  [ "$IS_MUTED" = "true" ] && exit 0
  [ "$VOL" -eq 0 ] 2>/dev/null && exit 0
  killall afplay 2>/dev/null
  afplay /System/Library/Sounds/Glass.aiff &
elif [[ -n "$WSL_DISTRO_NAME" ]]; then
  powershell.exe -Command "(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\tada.wav').PlaySync()" 2>/dev/null || printf '\a'
else
  printf '\a'
fi
