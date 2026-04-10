#!/usr/bin/env pwsh
# PostToolUse: lint edited files
#   .sh  → shellcheck (SC1090, SC1091 excluded)
#   .ps1 → PSScriptAnalyzer (if installed)

$raw  = [Console]::In.ReadToEnd()
$json = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
$FILE = $json.tool_input.file_path
if (-not $FILE) { exit 0 }

if ($FILE -like '*.sh') {
    if (Get-Command shellcheck -ErrorAction SilentlyContinue) {
        shellcheck --exclude=SC1090,SC1091 $FILE 2>&1
    }
} elseif ($FILE -like '*.ps1') {
    if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
        Invoke-ScriptAnalyzer $FILE | Format-Table -AutoSize | Out-String
    }
}
exit 0
