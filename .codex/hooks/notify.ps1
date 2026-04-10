#!/usr/bin/env pwsh
# Codex agent-turn-complete notification: Toast + sound (5-second debounce)

$LOCK_FILE = "$env:TEMP\codex-stop-cooldown"
$NOW = [DateTimeOffset]::Now.ToUnixTimeSeconds()

if (Test-Path $LOCK_FILE) {
    try {
        $LAST = [long](Get-Content $LOCK_FILE -Raw)
        if (($NOW - $LAST) -lt 5) { exit 0 }
    } catch {}
}
$NOW | Set-Content $LOCK_FILE

try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction SilentlyContinue
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
        [Windows.UI.Notifications.ToastTemplateType]::ToastText01)
    $template.SelectSingleNode('//text()').InnerText = 'Task completed'
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Codex')
    $notifier.Show([Windows.UI.Notifications.ToastNotification]::new($template))
} catch {}

try {
    $player = [System.Media.SoundPlayer]::new('C:\Windows\Media\ding.wav')
    $player.PlaySync()
} catch {
    [Console]::Beep()
}
