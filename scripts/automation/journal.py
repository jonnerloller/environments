#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

PACIFIC = ZoneInfo('America/Los_Angeles')
ROOT = Path(os.environ.get('DAILY_JOURNAL_ROOT', '/home/phitrine/Obsidian/valhalla/Areas/Personal/Dailies'))
LEGACY_ROOT = Path(os.environ.get('DAILY_JOURNAL_LEGACY_ROOT', '/home/phitrine/Obsidian/valhalla/dailies'))
DEFAULT_SECTION = 'What happened today'


def ensure_today_note() -> Path:
    ROOT.mkdir(parents=True, exist_ok=True)
    date = datetime.now(PACIFIC).date().isoformat()
    path = ROOT / f'{date}.md'
    legacy_path = LEGACY_ROOT / f'{date}.md'

    if path.exists():
        return path
    if legacy_path.exists():
        legacy_path.replace(path)
        return path

    path.write_text(
        f'# {date}\n\nTimezone: America/Los_Angeles\n\n## What happened today\n-\n\n## Anything interesting\n-\n\n## Current mental state\n-\n\n## Gratitude\n-\n\n## Reflection (optional)\n-\n',
        encoding='utf-8',
    )
    return path


def insert_bullet(path: Path, section: str, text: str) -> None:
    lines = path.read_text(encoding='utf-8').splitlines()
    heading = f'## {section}'

    start = None
    for idx, line in enumerate(lines):
        if line.strip() == heading:
            start = idx
            break
    if start is None:
        lines.extend(['', heading, f'- {text}'])
        path.write_text('\n'.join(lines) + '\n', encoding='utf-8')
        return

    end = len(lines)
    for idx in range(start + 1, len(lines)):
        if lines[idx].startswith('## '):
            end = idx
            break

    placeholder = None
    for idx in range(start + 1, end):
        if lines[idx].strip() == '-':
            placeholder = idx
            break

    if placeholder is not None:
        lines[placeholder] = f'- {text}'
    else:
        lines.insert(end, f'- {text}')

    path.write_text('\n'.join(lines) + '\n', encoding='utf-8')


def main() -> int:
    parser = argparse.ArgumentParser(description='Append a line to today’s daily journal.')
    parser.add_argument('text', nargs=argparse.REMAINDER, help='Journal text to append')
    parser.add_argument('--section', default=DEFAULT_SECTION)
    args = parser.parse_args()

    text = ' '.join(args.text).strip()
    if not text:
        parser.error('journal text is required')

    path = ensure_today_note()
    insert_bullet(path, args.section, text)
    print(f'Updated: {path.name}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
