#!/usr/bin/env python3
from __future__ import annotations

import datetime
import os
from pathlib import Path

import yaml

DOCKER_ROOT = Path(os.environ.get('DOCKER_ROOT', '/home/phitrine/docker'))
OUT = Path(os.environ.get('PORTS_REGISTRY_PATH', '/home/phitrine/Obsidian/valhalla/Resources/Infrastructure/PORTS.md'))

compose_files: list[Path] = []
for root, _, files in os.walk(DOCKER_ROOT):
    for filename in files:
        if filename in ('docker-compose.yml', 'compose.yml', 'compose.yaml'):
            compose_files.append(Path(root) / filename)

ports: list[tuple[int, str, str, str, str]] = []
for fp in compose_files:
    try:
        with fp.open() as fh:
            data = yaml.safe_load(fh) or {}
    except Exception:
        continue
    services = (data or {}).get('services', {}) or {}
    for service_name, service in services.items():
        for p in (service.get('ports') or []):
            if isinstance(p, int):
                ports.append((p, str(p), 'tcp', str(fp), service_name))
                continue
            ps = str(p)
            proto = 'tcp'
            if '/' in ps:
                ps, proto = ps.rsplit('/', 1)
            parts = ps.split(':')
            if len(parts) >= 2 and parts[-2].isdigit() and parts[-1].isdigit():
                ports.append((int(parts[-2]), parts[-1], proto, str(fp), service_name))

ports = sorted(set(ports), key=lambda x: (x[0], x[2], x[3], x[4]))

lines = [
    '# Port Registry',
    '',
    f"Last updated: {datetime.datetime.now(datetime.timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}",
    '',
    '## Declared in Docker Compose',
    '',
    '| Host Port | Proto | Container Port | Service | Stack |',
    '|---:|:---:|---:|---|---|',
]

for host_port, container_port, proto, fp, service_name in ports:
    rel = os.path.relpath(fp, DOCKER_ROOT)
    lines.append(f'| {host_port} | {proto} | {container_port} | `{service_name}` | `{rel}` |')

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text('\n'.join(lines) + '\n', encoding='utf-8')
print(f'Wrote {OUT} with {len(ports)} ports.')
