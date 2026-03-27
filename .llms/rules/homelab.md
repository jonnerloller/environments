# Homelab Rules

These rules apply to any AI agent operating on phitrine's homelab infrastructure.

## Docker
- All services go in `~/docker/<service-name>/` with their own `docker-compose.yml`
- Docker requires `sudo` on this system
- Use `restart: unless-stopped` for all services
- Check port conflicts before assigning new ports

## Networking
- Reverse proxy: Caddy at `~/docker/caddy/` with `tls internal`
- Service URLs: `<service>.services.phitrine.com`
- Host URLs: `<host>.home.phitrine.com`
- DNS server: 10.0.0.1
- Always remind about DNS records when adding new services

## Known Services and Ports
- Homepage: 3000
- Immich: 2283
- AirTrail: 3001
- Caddy: 80, 443
- Plex: 32400
