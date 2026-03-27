# Docker Service Setup

Set up a new Docker service following the homelab conventions.

## Instructions

1. Create the directory at `~/docker/$ARGUMENTS/`
2. Create a `docker-compose.yml` with the service configuration
3. Use `restart: unless-stopped` for all services
4. Add the service to the Caddy reverse proxy config at `~/docker/caddy/Caddyfile` with a new entry:
   ```
   $ARGUMENTS.services.phitrine.com {
     tls internal
     reverse_proxy localhost:<PORT>
   }
   ```
5. Reload Caddy: `sudo docker compose -f ~/docker/caddy/docker-compose.yml exec caddy caddy reload --config /etc/caddy/Caddyfile`
6. Remind the user to add a DNS record for `$ARGUMENTS.services.phitrine.com` pointing to phi-0
