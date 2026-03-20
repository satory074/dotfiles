#!/usr/bin/env python3
import json
import sys

data = json.load(sys.stdin)

BLOCKS = ' ▏▎▍▌▋▊▉█'
R = '\033[0m'
DIM = '\033[2m'


def gradient(pct):
    """True-color gradient: green → yellow → red."""
    p = max(0.0, min(1.0, pct / 100.0))
    if p <= 0.5:
        r = int(255 * p * 2)
        g = 255
    else:
        r = 255
        g = int(255 * (1 - (p - 0.5) * 2))
    return f'\033[38;2;{r};{g};0m'


def bar(pct, width=10):
    """Fine bar using 8 sub-block characters for smooth rendering."""
    filled = pct / 100.0 * width
    full = int(filled)
    frac = filled - full
    empty = width - full - (1 if frac > 0 else 0)
    block_idx = int(frac * 8)
    color = gradient(pct)
    result = color + '█' * full
    if frac > 0 and full < width:
        result += BLOCKS[block_idx]
    result += DIM + '░' * max(0, empty) + R
    return result


def fmt(label, pct):
    pct = round(pct)
    return f'{label} {bar(pct)} {pct}%'


model = data.get('model', {}).get('display_name', 'Claude')
ctx = data.get('context_window', {}).get('used_percentage')
five = data.get('rate_limits', {}).get('five_hour', {}).get('used_percentage')
week = data.get('rate_limits', {}).get('seven_day', {}).get('used_percentage')

parts = [model]
if ctx is not None:
    parts.append(fmt('ctx', ctx))
if five is not None:
    parts.append(fmt('5h', five))
if week is not None:
    parts.append(fmt('7d', week))

print(f'{DIM}│{R}'.join(f' {p} ' for p in parts), end='')
