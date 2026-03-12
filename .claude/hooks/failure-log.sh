#!/bin/bash
# PostToolUseFailure: エラーをJSONLで記録
LOG_DIR="$HOME/.claude/logs"
mkdir -p "$LOG_DIR"

jq -c '{
  timestamp: (now | todate),
  tool: .tool_name,
  error: .error_message,
  input: .tool_input
}' >> "$LOG_DIR/errors.jsonl" 2>/dev/null
exit 0
