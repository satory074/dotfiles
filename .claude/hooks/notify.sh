#!/bin/bash
# ミュートチェック（音量0も含む）
VOL_INFO=$(osascript -e "get volume settings")
IS_MUTED=$(echo "$VOL_INFO" | grep -o 'output muted:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
VOL=$(echo "$VOL_INFO" | grep -o 'output volume:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
[ "$IS_MUTED" = "true" ] && AUDIO_OFF=1
[ "$VOL" -eq 0 ] 2>/dev/null && AUDIO_OFF=1

# デバウンス: 3秒以内の連続呼び出しをスキップ
LOCK_FILE="/tmp/claude-notify-cooldown"
NOW=$(date +%s)
if [ -f "$LOCK_FILE" ]; then
  LAST=$(cat "$LOCK_FILE")
  ELAPSED=$(( NOW - LAST ))
  [ "$ELAPSED" -lt 3 ] && exit 0
fi
echo "$NOW" > "$LOCK_FILE"

# メッセージ取得（null/空文字ガード付き）
MSG=$(jq -r '.message // empty')
[ -z "$MSG" ] && exit 0

# 長すぎるメッセージを50文字で切る
MSG="${MSG:0:50}"

# macOS 通知センターに視覚的バナーを表示
osascript -e "display notification \"$MSG\" with title \"Claude Code\""

# 読み上げ（非同期: フックをブロックしない）
[ -z "$AUDIO_OFF" ] && say "$MSG" &
