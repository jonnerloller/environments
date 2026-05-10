#!/usr/bin/env python3
from __future__ import annotations

import os
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(os.environ.get('DAILY_JOURNAL_ROOT', '/home/phitrine/Obsidian/valhalla/Areas/Personal/Dailies'))
TEMPLATE = """# {date}

## What happened today
-

## Anything interesting
-

## Current mental state
-

## Gratitude
-

## Reflection (optional)
-
"""


def main() -> int:
    ROOT.mkdir(parents=True, exist_ok=True)
    date = datetime.now(timezone.utc).date().isoformat()
    path = ROOT / f'{date}.md'
    if path.exists():
        print(f'Exists: {path.name}')
        return 0
    path.write_text(TEMPLATE.format(date=date), encoding='utf-8')
    print(f'Created: {path.name}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
