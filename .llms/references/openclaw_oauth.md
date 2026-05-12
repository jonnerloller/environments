---
name: OpenClaw OAuth Setup
description: Port forwarding required to authenticate OpenClaw from a remote laptop via Tailscale/SSH
type: reference
---

## OpenClaw OAuth Setup (Remote Access)

When authenticating OpenClaw from a laptop while the server is remote, two ports must be forwarded:

- **1455** — OAuth callback (`localhost:1455/auth/callback`)
- **18789** — OpenClaw gateway (`gateway.port`)

### SSH Port Forward Command

```bash
ssh -N -L 1455:127.0.0.1:1455 -L 18789:127.0.0.1:18789 phitrine@10.0.0.8
```

Run this on the laptop before starting the OAuth flow, then open the auth URL in the laptop's browser.
