#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from datetime import datetime, timezone

data = json.load(sys.stdin)

# ---------- ANSI ----------
GREEN  = '\033[38;2;151;201;195m'
YELLOW = '\033[38;2;229;192;123m'
RED    = '\033[38;2;224;108;117m'
GRAY   = '\033[38;2;74;88;92m'
R      = '\033[0m'
DIM    = '\033[2m'

SEP = f'{GRAY} │ {R}'


def color(pct):
    if pct is None:
        return GRAY
    if pct >= 80:
        return RED
    if pct >= 50:
        return YELLOW
    return GREEN


def bar(pct, width=10):
    if pct is None:
        return '▱' * width
    filled = round(pct / 100 * width)
    filled = max(0, min(width, filled))
    return '▰' * filled + '▱' * (width - filled)


def fmt_reset(iso_str):
    """Format ISO 8601 reset time relative to now."""
    if not iso_str:
        return ''
    try:
        dt = datetime.fromisoformat(iso_str.replace('Z', '+00:00'))
        now = datetime.now(timezone.utc)
        diff = dt - now
        total = int(diff.total_seconds())
        if total <= 0:
            return 'now'
        h, rem = divmod(total, 3600)
        m = rem // 60
        if h > 0:
            return f'{h}h{m:02d}m'
        return f'{m}m'
    except Exception:
        return ''


# ---------- Extract fields ----------
model    = data.get('model', {}).get('display_name', 'Claude')
ctx      = data.get('context_window', {}).get('used_percentage')
cwd      = data.get('cwd', '')
added    = data.get('cost', {}).get('total_lines_added', 0)
removed  = data.get('cost', {}).get('total_lines_removed', 0)

rl       = data.get('rate_limits', {})
fh       = rl.get('five_hour', {})
sd       = rl.get('seven_day', {})
five_pct = fh.get('used_percentage')
week_pct = sd.get('used_percentage')
five_reset = fmt_reset(fh.get('reset_at'))
week_reset = fmt_reset(sd.get('reset_at'))

# ---------- Git branch ----------
git_branch = ''
if cwd and os.path.isdir(cwd):
    try:
        git_branch = subprocess.check_output(
            ['git', '-C', cwd, '--no-optional-locks', 'rev-parse', '--abbrev-ref', 'HEAD'],
            stderr=subprocess.DEVNULL, text=True
        ).strip()
    except Exception:
        pass

# ---------- cwd display ----------
home = os.path.expanduser('~')
cwd_display = cwd.replace(home, '~') if cwd else ''

# ---------- Line 1 ----------
ctx_pct = round(ctx) if ctx is not None else 0
parts1 = [f'🤖 {model}', f'{color(ctx_pct)}📊 {ctx_pct}%{R}']

if added or removed:
    parts1.append(f'✏️  {GREEN}+{added}/-{removed}{R}')
if cwd_display:
    parts1.append(f'📁 {cwd_display}')
if git_branch:
    parts1.append(f'🔀 {git_branch}')

line1 = SEP.join(parts1)

# ---------- Line 2 (5h) ----------
if five_pct is not None:
    p = round(five_pct)
    c = color(p)
    reset_str = f'  {DIM}Resets in {five_reset} (Asia/Tokyo){R}' if five_reset else ''
    line2 = f'{c}⏱ 5h  {bar(p)}  {p}%{R}{reset_str}'
else:
    line2 = f'{GRAY}⏱ 5h  {bar(None)}  --%{R}'

# ---------- Line 3 (7d) ----------
if week_pct is not None:
    p = round(week_pct)
    c = color(p)
    reset_str = f'  {DIM}Resets in {week_reset} (Asia/Tokyo){R}' if week_reset else ''
    line3 = f'{c}📅 7d  {bar(p)}  {p}%{R}{reset_str}'
else:
    line3 = f'{GRAY}📅 7d  {bar(None)}  --%{R}'

# ---------- Output ----------
print(line1)
print(line2)
print(line3, end='')
