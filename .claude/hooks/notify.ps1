#!/usr/bin/env pwsh
# Notification hook: Windows Toast + sound (15-second debounce)

$LOCK_FILE = "$env:TEMP\claude-notify-cooldown"
$NOW = [DateTimeOffset]::Now.ToUnixTimeSeconds()

if (Test-Path $LOCK_FILE) {
    try {
        $LAST = [long](Get-Content $LOCK_FILE -Raw)
        if (($NOW - $LAST) -lt 15) { exit 0 }
    } catch {}
}
$NOW | Set-Content $LOCK_FILE

$raw = [Console]::In.ReadToEnd()
$json = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue
$MSG = $json.message
if (-not $MSG) { exit 0 }
$MSG = $MSG.Substring(0, [Math]::Min(50, $MSG.Length))

try {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime -ErrorAction SilentlyContinue
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
        [Windows.UI.Notifications.ToastTemplateType]::ToastText01)
    $template.SelectSingleNode('//text()').InnerText = $MSG
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code')
    $notifier.Show([Windows.UI.Notifications.ToastNotification]::new($template))
} catch {}

try {
    $player = [System.Media.SoundPlayer]::new('C:\Windows\Media\ding.wav')
    $player.PlaySync()
} catch {
    [Console]::Beep()
}
