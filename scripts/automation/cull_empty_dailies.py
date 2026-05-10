#!/usr/bin/env python3
import os
import re
from pathlib import Path

ROOT = Path(os.environ.get('DAILY_JOURNAL_ROOT', '/home/phitrine/Obsidian/valhalla/Areas/Personal/Dailies'))

STRIP_LINE_PATTERNS = [
    r'^#\s+.*$',
    r'^##\s+.*$',
    r'^-\s*$',
    r'^(Mood:|Energy:|What’s on my mind:|Today I’m grateful for:|What felt good:|What felt hard:|One thing I want to carry into tomorrow:)\s*$',
]


def is_emptyish(text: str) -> bool:
    normalized = text.replace('\r\n', '\n').strip()
    if normalized.startswith('---\n'):
        parts = normalized.split('\n---\n', 1)
        if len(parts) == 2:
            normalized = parts[1].strip()
    for pattern in STRIP_LINE_PATTERNS:
        normalized = re.sub(pattern, '', normalized, flags=re.M)
    normalized = re.sub(r'\s+', '', normalized)
    return normalized == ''


def main() -> int:
    removed = []
    if not ROOT.exists():
        print(f'Missing dailies root: {ROOT}')
        return 1
    for path in sorted(ROOT.glob('*.md')):
        try:
            text = path.read_text(encoding='utf-8', errors='ignore')
        except Exception as exc:
            print(f'ERROR reading {path.name}: {exc}')
            continue
        if is_emptyish(text):
            path.unlink()
            removed.append(path.name)
    if removed:
        print('Removed empty/template-only dailies:')
        for name in removed:
            print(f'- {name}')
    else:
        print('No empty/template-only dailies found.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
