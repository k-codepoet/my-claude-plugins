# Split DNS Configuration

> Internal/External DNS resolution strategy.

## DNS Zones

| Zone | Domain Pattern | Resolution | Access |
|------|---------------|------------|--------|
| **External** | `*.{DOMAIN}` | Public DNS → CDN/Tunnel → Entry Point | Internet |
| **Internal** | `*.{INTERNAL_SUBDOMAIN}.{DOMAIN}` | VPN DNS → Entry Point VPN IP | VPN only |

## Resolution Flow

### External

```
Client → Public DNS (*.{DOMAIN})
  → CDN/Tunnel (e.g., Cloudflare)
  → Tunnel Agent → Entry Point Traefik (:80, HTTP)
  → Service
```

### Internal

```
Client (VPN) → VPN DNS resolver (*.{INTERNAL_SUBDOMAIN}.{DOMAIN})
  → Entry Point VPN IP ({VPN_IP})
  → Entry Point Traefik (:{HTTPS_PORT}, TLS termination)
  → Service
```

## VPN DNS Configuration

| Setting | Value |
|---------|-------|
| VPN Provider | {VPN_PROVIDER} (e.g., Tailscale) |
| DNS Name | `*.{INTERNAL_SUBDOMAIN}.{DOMAIN}` |
| Nameserver | {VPN_DNS_IP} |
| Split DNS domain | `{INTERNAL_SUBDOMAIN}.{DOMAIN}` |
| Resolve to | {ENTRY_POINT_VPN_IP} |

## LAN DNS (Optional)

For devices without VPN:

| Setting | Value |
|---------|-------|
| DNS Server | {LAN_DNS_SERVER} (e.g., AdGuard Home) |
| Rewrite Rule | `*.{INTERNAL_SUBDOMAIN}.{DOMAIN}` → {ENTRY_POINT_LAN_IP} |
