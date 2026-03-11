#!/bin/bash
# ミュートチェック（音量0も含む）
VOL_INFO=$(osascript -e "get volume settings")
IS_MUTED=$(echo "$VOL_INFO" | grep -o 'output muted:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
VOL=$(echo "$VOL_INFO" | grep -o 'output volume:[^,}]*' | awk -F: '{print $2}' | tr -d ' ')
[ "$IS_MUTED" = "true" ] && exit 0
[ "$VOL" -eq 0 ] 2>/dev/null && exit 0
afplay /System/Library/Sounds/Glass.aiff &
