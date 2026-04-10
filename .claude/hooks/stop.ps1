#!/usr/bin/env pwsh
# Stop hook: plays a sound on session end (5-second debounce)

$LOCK_FILE = "$env:TEMP\claude-stop-cooldown"
$NOW = [DateTimeOffset]::Now.ToUnixTimeSeconds()

if (Test-Path $LOCK_FILE) {
    try {
        $LAST = [long](Get-Content $LOCK_FILE -Raw)
        if (($NOW - $LAST) -lt 5) { exit 0 }
    } catch {}
}
$NOW | Set-Content $LOCK_FILE

try {
    $player = [System.Media.SoundPlayer]::new('C:\Windows\Media\tada.wav')
    $player.PlaySync()
} catch {
    [Console]::Beep()
}
