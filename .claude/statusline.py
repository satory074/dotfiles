#!/usr/bin/env python3
import json
import os
import subprocess
import sys
from datetime import datetime, timezone

data = json.load(sys.stdin)

# ---------- ANSI ----------
GREEN  = '\033[38;2;151;201;195m'
GRAY   = '\033[38;2;74;88;92m'
R      = '\033[0m'
DIM    = '\033[2m'

BLOCKS = ' ▏▎▍▌▋▊▉█'
SEP = f'{GRAY} │ {R}'


def gradient(pct):
    """True-color gradient: green → yellow → red."""
    p = max(0.0, min(1.0, pct / 100.0))
    if p <= 0.5:
        r, g = int(255 * p * 2), 255
    else:
        r, g = 255, int(255 * (1 - (p - 0.5) * 2))
    return f'\033[38;2;{r};{g};0m'


def color(pct):
    if pct is None:
        return GRAY
    return gradient(pct)


def bar(pct, width=10):
    """Fine bar with 8 sub-block characters."""
    if pct is None:
        return f'{DIM}' + '░' * width + R
    filled = pct / 100.0 * width
    full = int(filled)
    frac = filled - full
    empty = width - full - (1 if frac > 0 else 0)
    c = gradient(pct)
    result = c + '█' * full
    if frac > 0 and full < width:
        result += BLOCKS[int(frac * 8)]
    result += DIM + '░' * max(0, empty) + R
    return result


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
parts1 = [f'🤖 {model}']

if added or removed:
    parts1.append(f'✏️  {GREEN}+{added}/-{removed}{R}')
if cwd_display:
    parts1.append(f'📁 {cwd_display}')
if git_branch:
    parts1.append(f'🔀 {git_branch}')

line1 = SEP.join(parts1)

# ---------- Line 2 (bars) ----------
def fmt(label, pct):
    pct = round(pct)
    return f'{label} {bar(pct)} {pct}%'

parts2 = []
if ctx is not None: parts2.append(fmt('ctx', ctx))
if five_pct is not None: parts2.append(fmt('5h', five_pct))
if week_pct is not None: parts2.append(fmt('7d', week_pct))

line2 = f'{DIM}│{R}'.join(f' {p} ' for p in parts2)

# ---------- Output ----------
print(line1)
print(line2, end='')
