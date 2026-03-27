# Add Caddy Reverse Proxy Entry

Add a new site to the Caddy reverse proxy.

## Arguments
$ARGUMENTS should be in the format: `<service-name> <port>`

## Instructions

1. Read the current Caddyfile at `~/docker/caddy/Caddyfile`
2. Parse $ARGUMENTS — first word is the service name, second is the port
3. Add a new block:
   ```
   <service-name>.services.phitrine.com {
     tls internal
     reverse_proxy localhost:<port>
   }
   ```
4. Reload Caddy: `sudo docker compose -f ~/docker/caddy/docker-compose.yml exec caddy caddy reload --config /etc/caddy/Caddyfile`
5. Remind the user to add a DNS record at 10.0.0.1
