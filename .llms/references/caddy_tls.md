---
name: Caddy + Let's Encrypt (DNS-01 via Cloudflare)
description: Caddy reverse proxy on phi-0 issues publicly trusted Let's Encrypt certs for *.services.phitrine.com using DNS-01 against Cloudflare; no inbound port forward required.
type: reference
---

**Reverse proxy:** Caddy at `~/docker/caddy/` (Docker, container `caddy`). Custom image `caddy-cloudflare:local` built from `~/docker/caddy/Dockerfile`.

**Image build recipe** (`~/docker/caddy/Dockerfile`):
```Dockerfile
FROM caddy:builder AS builder
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare

FROM caddy:latest
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
```
Rebuild after Caddy version bump or DNS-module change: `cd ~/docker/caddy && docker compose up -d --build`.

**Compose snippet** (`~/docker/caddy/docker-compose.yml`):
- `build: .` + `image: caddy-cloudflare:local`
- `env_file: - cf-token.env`  (sources `CF_API_TOKEN` into the container)
- `ports: 80, 443`; `dns: 10.0.0.1`

**Cloudflare API token** (`~/docker/caddy/cf-token.env`, chmod 600):
- Single line: `CF_API_TOKEN=cfat_…`
- Scoped to zone `phitrine.com` with **Zone:DNS:Edit** + **Zone:Zone:Read** permissions.
- Backed up to Bitwarden as `cloudflare_caddy_token` (custom field `token`) in Homelab Secrets.

**Caddyfile global ACME config** (`~/docker/caddy/caddy/Caddyfile`):
```caddyfile
{
  email chen.enhan.jonathan@gmail.com
  acme_dns cloudflare {env.CF_API_TOKEN}
}
```
Every site block below is just `<host> { reverse_proxy <upstream> }` — no `tls` directive needed; the global `acme_dns` applies to all sites and triggers per-host DNS-01 challenges automatically.

**DNS:** wildcard `*.services.phitrine.com → 10.0.0.8` (phi-0) lives at Cloudflare. Internal DNS at 10.0.0.1 mirrors this for LAN clients. Both are needed: Cloudflare so Let's Encrypt's DNS-01 challenge can read the `_acme-challenge.<host>` TXT records, and the LAN resolver so clients on the network can reach phi-0 directly without going through Cloudflare.

**Why DNS-01, not HTTP-01:** phi-0 sits behind a home router with no inbound port forwarding. HTTP-01 needs port 80 reachable from the public Internet, which we don't have. DNS-01 only needs outbound HTTPS to Cloudflare's API and Let's Encrypt's ACME endpoint.

**Rate-limit awareness:** Let's Encrypt's production endpoint allows 50 certs per registered domain per week and 5 duplicate certs per week. We're well under both. Caddy stores certs in the `caddy_data` named volume and renews ~30 days before expiry.

**Snap-Docker bind-mount quirk:** Editing `caddy/Caddyfile` and running `caddy reload` may not pick up the change because snap-Docker bind mounts can serve a stale snapshot inside the container. Workaround: `docker compose restart` (or `up -d`) the caddy service — the bind mount refreshes at container start.

**Adding a new service:** edit the Caddyfile, add a `<host>.services.phitrine.com { reverse_proxy <upstream> }` block, then `docker compose restart` caddy. The first request will trigger DNS-01 and provision a real cert in ~10-30s. No DNS work needed (wildcard already routes).

**Removing all the `--cacert` / `NODE_EXTRA_CA_CERTS` workarounds:** the historical `~/docker/caddy/caddy-root.crt` was Caddy's internal CA, needed back when sites used `tls internal`. Since switching to public Let's Encrypt certs, no client needs to trust an internal CA — every modern HTTP library trusts Let's Encrypt out of the box. References in scripts have been removed; the cert file on disk is harmless but unused.

**Failure modes & recovery:**
- Cloudflare API token revoked or rotated → Caddy logs DNS-01 failures, sites still serve last cached cert until expiry (~90 days). Update `cf-token.env` and `docker compose restart`.
- Cloudflare API outage during renewal → cached cert keeps serving; Caddy retries on a backoff. No action needed unless outage exceeds renewal window.
- Caddy can't reach Let's Encrypt at startup → sites won't have certs and will return TLS errors. Same Cloudflare-side check, and check phi-0's outbound HTTPS.
- Lost the Caddy data volume → all certs re-issued on next start (well within rate limits given we have ~10 sites).
