# Traefik Reverse Proxy Chain

> Multi-node reverse proxy chain topology.

## Chain Topology

```
External (*.{DOMAIN}):
  Internet → CDN/Tunnel → Tunnel Agent ({TUNNEL_DEVICE})
           → Entry Point Traefik ({ENTRY_DEVICE}:{HTTPS_PORT}, ACME TLS termination)
           → Chain Node Traefik ({CHAIN_NODE_1}:HTTP) → ... → 404 fallback

Internal (*.{INTERNAL_SUBDOMAIN}.{DOMAIN}):
  Split DNS → Entry Point VPN IP
            → Entry Point Traefik (:{HTTPS_PORT}, TLS termination)
            → Chain Node Traefik (HTTP) → ... → 404 fallback
```

## Node Roles

| Node | Device | Role | Port | Network |
|------|--------|------|------|---------|
| Entry Point | {ENTRY_DEVICE} | TLS termination, ACME certificates | {HTTPS_PORT} | {NETWORK_1} |
| Chain Node 1 | {CHAIN_DEVICE_1} | Local service routing, fallback to next | {CHAIN_PORT_1} | {NETWORK_2} |
| Chain Node N | {CHAIN_DEVICE_N} | Local service routing, 404 fallback | {CHAIN_PORT_N} | {NETWORK_N} |

## Entry Point Configuration

- ACME wildcard certificates: `*.{DOMAIN}`, `*.{INTERNAL_SUBDOMAIN}.{DOMAIN}`
- DNS Challenge provider: {DNS_PROVIDER} (e.g., Cloudflare)
- Certificate storage: `{CERT_STORAGE_PATH}`

## Chain Fallback Router

Each chain node has a catch-all fallback router:

```yaml
# Lowest priority: forwards unmatched traffic to next node
- "traefik.http.routers.chain-fallback.rule=HostRegexp(`.+`)"
- "traefik.http.routers.chain-fallback.priority=1"
- "traefik.http.services.chain-fallback.loadbalancer.server.url=http://{NEXT_NODE_IP}:{NEXT_NODE_PORT}"
```

## Priority Rules

| Priority | Purpose | Example |
|----------|---------|---------|
| 100 | Dashboard router | Traefik dashboard |
| 10+ | Docker Provider auto-discovered services | Default (service labels) |
| 1 | Chain fallback router | `HostRegexp(.+) → next node` |
