#!/usr/bin/env pwsh
# PostToolUseFailure: log errors to ~/.claude/logs/errors.jsonl

$LOG_DIR = "$HOME\.claude\logs"
New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null

$raw  = [Console]::In.ReadToEnd()
$json = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue

$entry = [ordered]@{
    timestamp = [DateTimeOffset]::UtcNow.ToString('o')
    tool      = $json.tool_name
    error     = $json.error_message
    input     = $json.tool_input
}

($entry | ConvertTo-Json -Compress) | Add-Content "$LOG_DIR\errors.jsonl"
exit 0
