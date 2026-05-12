#!/usr/bin/env python3
from __future__ import annotations

import os
from datetime import datetime
from pathlib import Path
from zoneinfo import ZoneInfo

PACIFIC = ZoneInfo('America/Los_Angeles')
ROOT = Path(os.environ.get('DAILY_JOURNAL_ROOT', '/home/phitrine/Obsidian/valhalla/Areas/Personal/Dailies'))
LEGACY_ROOT = Path(os.environ.get('DAILY_JOURNAL_LEGACY_ROOT', '/home/phitrine/Obsidian/valhalla/dailies'))
TEMPLATE = """# {date}

Timezone: America/Los_Angeles

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
    date = datetime.now(PACIFIC).date().isoformat()
    path = ROOT / f'{date}.md'
    legacy_path = LEGACY_ROOT / f'{date}.md'

    if path.exists():
        print(f'Exists: {path.name}')
        return 0

    if legacy_path.exists():
        legacy_path.replace(path)
        print(f'Moved: {legacy_path.name} -> {path}')
        return 0

    path.write_text(TEMPLATE.format(date=date), encoding='utf-8')
    print(f'Created: {path.name}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
