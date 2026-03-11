#!/bin/bash
# Claude Code statusline script
# Line 1: Model | Context% | +added/-removed | git branch
# Line 2: 5h rate limit progress bar
# Line 3: 7d rate limit progress bar

input=$(cat)

# ---------- ANSI Colors ----------
GREEN=$'\e[38;2;151;201;195m'
YELLOW=$'\e[38;2;229;192;123m'
RED=$'\e[38;2;224;108;117m'
GRAY=$'\e[38;2;74;88;92m'
RESET=$'\e[0m'
DIM=$'\e[2m'

# ---------- Color by percentage ----------
color_for_pct() {
  local pct="$1"
  if [ -z "$pct" ] || [ "$pct" = "null" ]; then
    printf '%s' "$GRAY"
    return
  fi
  local ipct
  ipct=$(printf "%.0f" "$pct" 2>/dev/null || echo "0")
  if [ "$ipct" -ge 80 ]; then
    printf '%s' "$RED"
  elif [ "$ipct" -ge 50 ]; then
    printf '%s' "$YELLOW"
  else
    printf '%s' "$GREEN"
  fi
}

# ---------- Progress bar (10 segments) ----------
progress_bar() {
  local pct="$1"
  local filled
  filled=$(awk "BEGIN{printf \"%d\", int($pct / 10 + 0.5)}" 2>/dev/null || echo 0)
  [ "$filled" -gt 10 ] 2>/dev/null && filled=10
  [ "$filled" -lt 0 ] 2>/dev/null && filled=0
  local bar=""
  for i in $(seq 1 10); do
    if [ "$i" -le "$filled" ]; then
      bar="${bar}▰"
    else
      bar="${bar}▱"
    fi
  done
  printf '%s' "$bar"
}

# ---------- Parse stdin (single jq call) ----------
eval "$(echo "$input" | jq -r '
  "model_name=" + (.model.display_name // "Unknown" | @sh),
  "used_pct=" + (.context_window.used_percentage // 0 | tostring),
  "cwd=" + (.cwd // "" | @sh),
  "lines_added=" + (.cost.total_lines_added // 0 | tostring),
  "lines_removed=" + (.cost.total_lines_removed // 0 | tostring),
  "cc_version=" + (.version // "0.0.0" | @sh)
' 2>/dev/null)"

# ---------- Git branch ----------
git_branch=""
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  git_branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null || true)
fi

# cwd を ~ 表記に変換
cwd_display=""
if [ -n "$cwd" ]; then
  cwd_display=$(echo "$cwd" | sed "s|^$HOME|~|")
fi

# ---------- Line stats from stdin ----------
git_stats=""
if [ "$lines_added" -gt 0 ] 2>/dev/null || [ "$lines_removed" -gt 0 ] 2>/dev/null; then
  git_stats="+${lines_added}/-${lines_removed}"
fi

# ---------- Rate limit via OAuth usage API (cached 360s) ----------
CACHE_FILE="/tmp/claude-usage-cache.json"
CACHE_TTL=360
FIVE_HOUR_UTIL=""
FIVE_HOUR_RESET=""
SEVEN_DAY_UTIL=""
SEVEN_DAY_RESET=""

fetch_usage() {
  local raw_token
  raw_token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
  [ -z "$raw_token" ] && return 1

  # Keychain value may be hex-encoded; try decoding
  local token
  if echo "$raw_token" | grep -qE '^[0-9a-fA-F]+$'; then
    token=$(echo "$raw_token" | xxd -r -p 2>/dev/null || echo "$raw_token")
  else
    token="$raw_token"
  fi

  # Extract OAuth access token from JSON wrapper
  local access_token json_str
  json_str=$(echo "$token" | sed 's/^[^{]*//')
  access_token=$(echo "$json_str" | jq -r '.claudeAiOauth.accessToken // .accessToken // empty' 2>/dev/null)
  [ -z "$access_token" ] && return 1

  # Clear CURL_CA_BUNDLE if the file doesn't exist (avoids macOS vs Linux path mismatch)
  local _curl=(curl)
  [ -n "${CURL_CA_BUNDLE:-}" ] && [ ! -f "$CURL_CA_BUNDLE" ] && _curl=(env -u CURL_CA_BUNDLE curl)

  # Fetch usage via OAuth endpoint (returns JSON with utilization percentages)
  local response
  response=$("${_curl[@]}" -s --max-time 8 \
    -H "Authorization: Bearer ${access_token}" \
    -H "Content-Type: application/json" \
    -H "anthropic-beta: oauth-2025-04-20" \
    "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || true
  [ -z "$response" ] && return 1

  # Parse JSON response (utilization is 0-100 percentage, resets_at is ISO 8601)
  local h5_util h5_reset_iso h7_util h7_reset_iso
  h5_util=$(echo "$response" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
  h5_reset_iso=$(echo "$response" | jq -r '.five_hour.resets_at // empty' 2>/dev/null)
  h7_util=$(echo "$response" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
  h7_reset_iso=$(echo "$response" | jq -r '.seven_day.resets_at // empty' 2>/dev/null)
  [ -z "$h5_util" ] && return 1

  # Convert ISO 8601 timestamps to epoch seconds
  local h5_reset h7_reset
  h5_reset=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${h5_reset_iso%%[+Z]*}" "+%s" 2>/dev/null || \
             date -d "$h5_reset_iso" "+%s" 2>/dev/null || echo "0")
  h7_reset=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${h7_reset_iso%%[+Z]*}" "+%s" 2>/dev/null || \
             date -d "$h7_reset_iso" "+%s" 2>/dev/null || echo "0")

  # Save to cache as JSON
  jq -n \
    --arg h5u "$h5_util" --arg h5r "$h5_reset" \
    --arg h7u "$h7_util" --arg h7r "$h7_reset" \
    '{five_hour_util: $h5u, five_hour_reset: $h5r, seven_day_util: $h7u, seven_day_reset: $h7r}' \
    > "$CACHE_FILE"
  return 0
}

load_usage() {
  local data="$1"
  eval "$(echo "$data" | jq -r '
    "FIVE_HOUR_UTIL=" + (.five_hour_util // empty),
    "FIVE_HOUR_RESET=" + (.five_hour_reset // empty),
    "SEVEN_DAY_UTIL=" + (.seven_day_util // empty),
    "SEVEN_DAY_RESET=" + (.seven_day_reset // empty)
  ' 2>/dev/null)"
}

# Check cache validity
USE_CACHE=false
if [ -f "$CACHE_FILE" ]; then
  cache_age=$(( $(date +%s) - $(stat -f '%m' "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [ "$cache_age" -lt "$CACHE_TTL" ]; then
    USE_CACHE=true
  fi
fi

if $USE_CACHE; then
  load_usage "$(cat "$CACHE_FILE")"
else
  if fetch_usage; then
    load_usage "$(cat "$CACHE_FILE")"
  elif [ -f "$CACHE_FILE" ]; then
    load_usage "$(cat "$CACHE_FILE")"
  fi
fi

# Round utilization percentage (already 0-100 from OAuth usage API)
to_pct() {
  local val="$1"
  if [ -z "$val" ] || [ "$val" = "null" ] || [ "$val" = "0" ]; then
    echo ""
    return
  fi
  awk "BEGIN{printf \"%.0f\", $val}" 2>/dev/null || echo ""
}

FIVE_HOUR_PCT=$(to_pct "$FIVE_HOUR_UTIL")
SEVEN_DAY_PCT=$(to_pct "$SEVEN_DAY_UTIL")

# ---------- Format reset time (from epoch seconds) ----------
format_epoch_time() {
  local epoch="$1"
  local format="$2"
  [ -z "$epoch" ] || [ "$epoch" = "0" ] && echo "" && return
  local result
  result=$(TZ="Asia/Tokyo" date -j -f "%s" "$epoch" "$format" 2>/dev/null || \
           TZ="Asia/Tokyo" date -d "@${epoch}" "$format" 2>/dev/null || echo "")
  echo "$result" | sed 's/AM/am/;s/PM/pm/'
}

five_reset_display=""
if [ -n "$FIVE_HOUR_RESET" ] && [ "$FIVE_HOUR_RESET" != "0" ]; then
  five_reset_display="Resets $(format_epoch_time "$FIVE_HOUR_RESET" "+%-I%p") (Asia/Tokyo)"
fi

seven_reset_display=""
if [ -n "$SEVEN_DAY_RESET" ] && [ "$SEVEN_DAY_RESET" != "0" ]; then
  seven_reset_display="Resets $(format_epoch_time "$SEVEN_DAY_RESET" "+%b %-d at %-I%p") (Asia/Tokyo)"
fi

# ---------- Format context used% ----------
ctx_pct_int=0
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ] && [ "$used_pct" != "0" ]; then
  ctx_pct_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo 0)
fi

# ---------- Line 1 ----------
SEP="${GRAY} │ ${RESET}"
ctx_color=$(color_for_pct "$ctx_pct_int")

line1="🤖 ${model_name}${SEP}${ctx_color}📊 ${ctx_pct_int}%${RESET}"

if [ -n "$git_stats" ]; then
  line1+="${SEP}✏️  ${GREEN}${git_stats}${RESET}"
fi

if [ -n "$cwd_display" ]; then
  line1+="${SEP}📁 ${cwd_display}"
fi

if [ -n "$git_branch" ]; then
  line1+="${SEP}🔀 ${git_branch}"
fi

# ---------- Line 2 (5h) ----------
line2=""
if [ -n "$FIVE_HOUR_PCT" ]; then
  c5=$(color_for_pct "$FIVE_HOUR_PCT")
  bar5=$(progress_bar "$FIVE_HOUR_PCT")
  line2="${c5}⏱ 5h  ${bar5}  ${FIVE_HOUR_PCT}%${RESET}"
  [ -n "$five_reset_display" ] && line2+="  ${DIM}${five_reset_display}${RESET}"
else
  line2="${GRAY}⏱ 5h  ▱▱▱▱▱▱▱▱▱▱  --%${RESET}"
fi

# ---------- Line 3 (7d) ----------
line3=""
if [ -n "$SEVEN_DAY_PCT" ]; then
  c7=$(color_for_pct "$SEVEN_DAY_PCT")
  bar7=$(progress_bar "$SEVEN_DAY_PCT")
  line3="${c7}📅 7d  ${bar7}  ${SEVEN_DAY_PCT}%${RESET}"
  [ -n "$seven_reset_display" ] && line3+="  ${DIM}${seven_reset_display}${RESET}"
else
  line3="${GRAY}📅 7d  ▱▱▱▱▱▱▱▱▱▱  --%${RESET}"
fi

# ---------- Output ----------
printf '%s\n' "$line1"
printf '%s\n' "$line2"
printf '%s' "$line3"
