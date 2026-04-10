#!/usr/bin/env pwsh
# PostToolUse hook: plays a sound on tool use (3-second debounce)

$LOCK_FILE = "$env:TEMP\claude-posttooluse-cooldown"
$NOW = [DateTimeOffset]::Now.ToUnixTimeSeconds()

if (Test-Path $LOCK_FILE) {
    try {
        $LAST = [long](Get-Content $LOCK_FILE -Raw)
        if (($NOW - $LAST) -lt 3) { exit 0 }
    } catch {}
}
$NOW | Set-Content $LOCK_FILE

try {
    $player = [System.Media.SoundPlayer]::new('C:\Windows\Media\ding.wav')
    $player.PlaySync()
} catch {
    [Console]::Beep()
}
