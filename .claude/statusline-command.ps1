#!/usr/bin/env pwsh
# Claude Code statusline script (PowerShell port of statusline-command.sh)
# Line 1: Model | Context% | +added/-removed | cwd | git branch
# Line 2: 5h rate limit progress bar
# Line 3: 7d rate limit progress bar

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# ---------- ANSI Colors ----------
$ESC    = [char]27
$GREEN  = "$ESC[38;2;151;201;195m"
$YELLOW = "$ESC[38;2;229;192;123m"
$RED    = "$ESC[38;2;224;108;117m"
$GRAY   = "$ESC[38;2;74;88;92m"
$RESET  = "$ESC[0m"
$DIM    = "$ESC[2m"

# ---------- Color by percentage ----------
function Get-ColorForPct {
    param($pct)
    if (-not $pct -or $pct -eq 'null') { return $GRAY }
    try {
        $i = [int][Math]::Round([double]$pct)
        if ($i -ge 80) { return $RED }
        if ($i -ge 50) { return $YELLOW }
        return $GREEN
    } catch { return $GRAY }
}

# ---------- Progress bar (10 segments) ----------
function Get-ProgressBar {
    param($pct)
    try {
        $filled = [int][Math]::Min(10, [Math]::Max(0, [Math]::Round([double]$pct / 10)))
        return ('▰' * $filled) + ('▱' * (10 - $filled))
    } catch {
        return '▱▱▱▱▱▱▱▱▱▱'
    }
}

# ---------- Parse stdin ----------
$raw = [Console]::In.ReadToEnd()
$data = $raw | ConvertFrom-Json -ErrorAction SilentlyContinue

$model_name    = $data.model.display_name ?? 'Unknown'
$used_pct      = [double]($data.context_window.used_percentage ?? 0)
$cwd           = $data.cwd ?? ''
$lines_added   = [int]($data.cost.total_lines_added ?? 0)
$lines_removed = [int]($data.cost.total_lines_removed ?? 0)

# ---------- Git branch ----------
$git_branch = ''
if ($cwd -and (Test-Path $cwd)) {
    try {
        $git_branch = (git -C $cwd --no-optional-locks rev-parse --abbrev-ref HEAD 2>$null)?.Trim()
    } catch {}
}

# ---------- cwd display (replace $HOME with ~) ----------
$cwd_display = ''
if ($cwd) {
    $cwd_display = $cwd -replace [regex]::Escape($HOME), '~'
}

# ---------- Line stats ----------
$git_stats = ''
if ($lines_added -gt 0 -or $lines_removed -gt 0) {
    $git_stats = "+${lines_added}/-${lines_removed}"
}

# ---------- Rate limit via OAuth usage API (cached 360s) ----------
$CACHE_FILE = "$env:TEMP\claude-usage-cache.json"
$CACHE_TTL  = 360

$script:FIVE_HOUR_UTIL  = ''
$script:FIVE_HOUR_RESET = '0'
$script:SEVEN_DAY_UTIL  = ''
$script:SEVEN_DAY_RESET = '0'

function Get-AccessToken {
    $credPath = "$HOME\.claude\.credentials.json"
    if (Test-Path $credPath) {
        try {
            $creds = Get-Content $credPath -Raw | ConvertFrom-Json
            $token = $creds.claudeAiOauth.accessToken
            if (-not $token) { $token = $creds.accessToken }
            if ($token) { return $token }
        } catch {}
    }
    return $null
}

function Invoke-UsageAPI {
    $access_token = Get-AccessToken
    if (-not $access_token) { return $false }

    $headers = @{
        'Authorization'  = "Bearer $access_token"
        'Content-Type'   = 'application/json'
        'anthropic-beta' = 'oauth-2025-04-20'
    }

    try {
        $params = @{
            Uri        = 'https://api.anthropic.com/api/oauth/usage'
            Headers    = $headers
            TimeoutSec = 8
            Method     = 'GET'
        }
        if ($env:CURL_CA_BUNDLE -and (Test-Path $env:CURL_CA_BUNDLE)) {
            $params['Certificate'] = $null  # Use system store
        }
        $response = Invoke-RestMethod @params -ErrorAction Stop
    } catch {
        return $false
    }

    $h5_util      = $response.five_hour.utilization
    $h5_reset_iso = $response.five_hour.resets_at
    $h7_util      = $response.seven_day.utilization
    $h7_reset_iso = $response.seven_day.resets_at

    if ($null -eq $h5_util) { return $false }

    $h5_reset = 0; $h7_reset = 0
    try { $h5_reset = [DateTimeOffset]::Parse($h5_reset_iso).ToUnixTimeSeconds() } catch {}
    try { $h7_reset = [DateTimeOffset]::Parse($h7_reset_iso).ToUnixTimeSeconds() } catch {}

    [ordered]@{
        five_hour_util  = $h5_util
        five_hour_reset = $h5_reset
        seven_day_util  = $h7_util
        seven_day_reset = $h7_reset
    } | ConvertTo-Json -Compress | Set-Content $CACHE_FILE -Encoding UTF8
    return $true
}

function Read-UsageCache {
    param($path)
    try {
        $d = Get-Content $path -Raw | ConvertFrom-Json
        $script:FIVE_HOUR_UTIL  = $d.five_hour_util
        $script:FIVE_HOUR_RESET = $d.five_hour_reset
        $script:SEVEN_DAY_UTIL  = $d.seven_day_util
        $script:SEVEN_DAY_RESET = $d.seven_day_reset
    } catch {}
}

$use_cache = $false
if (Test-Path $CACHE_FILE) {
    try {
        $age = [DateTimeOffset]::Now.ToUnixTimeSeconds() -
               [DateTimeOffset]::new((Get-Item $CACHE_FILE).LastWriteTimeUtc).ToUnixTimeSeconds()
        if ($age -lt $CACHE_TTL) { $use_cache = $true }
    } catch {}
}

if ($use_cache) {
    Read-UsageCache $CACHE_FILE
} else {
    if (Invoke-UsageAPI) {
        Read-UsageCache $CACHE_FILE
    } elseif (Test-Path $CACHE_FILE) {
        Read-UsageCache $CACHE_FILE
    }
}

# ---------- Percentage helper ----------
function ConvertTo-Pct {
    param($val)
    if (-not $val -or $val -eq '0' -or $val -eq 0) { return '' }
    try { return [string][int][Math]::Round([double]$val) } catch { return '' }
}

$FIVE_HOUR_PCT = ConvertTo-Pct $script:FIVE_HOUR_UTIL
$SEVEN_DAY_PCT = ConvertTo-Pct $script:SEVEN_DAY_UTIL

# ---------- Format reset time (epoch → Asia/Tokyo display) ----------
function Format-EpochTime {
    param($epoch, [string]$fmt)
    if (-not $epoch -or $epoch -eq '0' -or $epoch -eq 0) { return '' }
    try {
        $tz = [TimeZoneInfo]::FindSystemTimeZoneById('Tokyo Standard Time')
        $dt = [DateTimeOffset]::FromUnixTimeSeconds([long]$epoch)
        $local = [TimeZoneInfo]::ConvertTime($dt, $tz)
        return $local.ToString($fmt)
    } catch { return '' }
}

$five_reset_display  = ''
if ($script:FIVE_HOUR_RESET -and $script:FIVE_HOUR_RESET -ne '0') {
    $t = Format-EpochTime $script:FIVE_HOUR_RESET 'h tt'
    if ($t) { $five_reset_display = "Resets $t (Asia/Tokyo)" }
}

$seven_reset_display = ''
if ($script:SEVEN_DAY_RESET -and $script:SEVEN_DAY_RESET -ne '0') {
    $t = Format-EpochTime $script:SEVEN_DAY_RESET 'MMM d \a\t h tt'
    if ($t) { $seven_reset_display = "Resets $t (Asia/Tokyo)" }
}

# ---------- Context % ----------
$ctx_pct_int = 0
if ($used_pct) {
    try { $ctx_pct_int = [int][Math]::Round($used_pct) } catch {}
}

# ---------- Line 1 ----------
$SEP       = "${GRAY} │ ${RESET}"
$ctx_color = Get-ColorForPct $ctx_pct_int

$line1 = "🤖 ${model_name}${SEP}${ctx_color}📊 ${ctx_pct_int}%${RESET}"
if ($git_stats)   { $line1 += "${SEP}✏️  ${GREEN}${git_stats}${RESET}" }
if ($cwd_display) { $line1 += "${SEP}📁 ${cwd_display}" }
if ($git_branch)  { $line1 += "${SEP}🔀 ${git_branch}" }

# ---------- Line 2 (5h) ----------
if ($FIVE_HOUR_PCT) {
    $c5    = Get-ColorForPct $FIVE_HOUR_PCT
    $bar5  = Get-ProgressBar  $FIVE_HOUR_PCT
    $line2 = "${c5}⏱ 5h  ${bar5}  ${FIVE_HOUR_PCT}%${RESET}"
    if ($five_reset_display) { $line2 += "  ${DIM}${five_reset_display}${RESET}" }
} else {
    $line2 = "${GRAY}⏱ 5h  ▱▱▱▱▱▱▱▱▱▱  --%${RESET}"
}

# ---------- Line 3 (7d) ----------
if ($SEVEN_DAY_PCT) {
    $c7    = Get-ColorForPct $SEVEN_DAY_PCT
    $bar7  = Get-ProgressBar  $SEVEN_DAY_PCT
    $line3 = "${c7}📅 7d  ${bar7}  ${SEVEN_DAY_PCT}%${RESET}"
    if ($seven_reset_display) { $line3 += "  ${DIM}${seven_reset_display}${RESET}" }
} else {
    $line3 = "${GRAY}📅 7d  ▱▱▱▱▱▱▱▱▱▱  --%${RESET}"
}

# ---------- Output ----------
[Console]::WriteLine($line1)
[Console]::WriteLine($line2)
[Console]::Write($line3)
