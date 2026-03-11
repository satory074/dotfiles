#!/bin/bash
# ミュートチェック（音量0も含む）
VOL_INFO=$(osascript -e "get volume settings")
IS_MUTED=$(echo "$VOL_INFO" | grep -o 'output muted:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
VOL=$(echo "$VOL_INFO" | grep -o 'output volume:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
[ "$IS_MUTED" = "true" ] && AUDIO_OFF=1
[ "$VOL" -eq 0 ] 2>/dev/null && AUDIO_OFF=1

# デバウンス: 15秒以内の連続呼び出しをスキップ（say の発話時間をカバー）
LOCK_FILE="/tmp/claude-notify-cooldown"
NOW=$(date +%s)
if [ -f "$LOCK_FILE" ]; then
  LAST=$(cat "$LOCK_FILE")
  ELAPSED=$(( NOW - LAST ))
  [ "$ELAPSED" -lt 15 ] && exit 0
fi
echo "$NOW" > "$LOCK_FILE"

# メッセージ取得（null/空文字ガード付き）
MSG=$(jq -r '.message // empty')
[ -z "$MSG" ] && exit 0

# 長すぎるメッセージを50文字で切る
MSG="${MSG:0:50}"

# macOS 通知センターに視覚的バナーを表示
osascript -e "display notification \"$MSG\" with title \"Claude Code\""

# 読み上げ（前の say を止めてから新しいものを起動）
if [ -z "$AUDIO_OFF" ]; then
  killall say 2>/dev/null
  pkill -f "xargs say" 2>/dev/null
  say "$MSG" &
fi
