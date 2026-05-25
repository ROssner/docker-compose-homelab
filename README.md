# 🐳 Docker Compose Homelab

A production-grade homelab infrastructure using Docker Compose, covering observability, reverse proxy with TLS, centralized logging, and a full web application stack.

Designed as a local mirror of cloud-native patterns — every stack maps directly to an AWS equivalent.

## 📐 Architecture
                         ┌───────────────────────────────────┐
                         │           Traefik (v3)            │
                         │  Reverse Proxy + TLS + Dashboard  │
                         └─────────────────┬─────────────────┘
                                           │
                              traefik-public network
                                           │
        ┌──────────────────────────────────┼──────────────────────────────────┐
        │                                  │                                  │
┌───────▼────────┐              ┌──────────▼──────────┐             ┌────────▼─────────┐
│    Web Stack   │              │     Monitoring      │             │     Logging      │
├────────────────┤              ├─────────────────────┤             ├──────────────────┤
│ Nginx          │              │ Prometheus          │             │ Loki             │
│ Node.js App    │              │ Grafana             │             │ Promtail         │
│ PostgreSQL     │              │ Alertmanager        │             │                  │
│ Redis          │              │ Node Exporter       │             │                  │
│ PG Exporter    │              │ cAdvisor            │             │                  │
└────────────────┘              └─────────────────────┘             └──────────────────┘
## 🗂️ Stacks

| Stack | Services | AWS Equivalent |
|-------|----------|---------------|
| `traefik/` | Traefik v3 | ALB + ACM |
| `monitoring/` | Prometheus, Grafana, Alertmanager, Node Exporter, cAdvisor | CloudWatch + Managed Grafana |
| `webstack/` | Nginx, Node.js, PostgreSQL, Redis, PG Exporter | EC2 + RDS + ElastiCache |
| `logging/` | Loki, Promtail | CloudWatch Logs |

## 🚀 Quick Start

```bash
# Copy and fill in environment variables
cp .env.example .env

# Start everything
make up

# Start a single stack
make up STACK=monitoring

# View logs
make logs STACK=monitoring

# Health check all services
make health

# Backup volumes
make backup
```

## 🔒 Security Features

- All external traffic routes through Traefik with automatic HTTPS (Let's Encrypt)
- Dashboard protected with Basic Auth
- Nginx rate limiting (API: 10r/s, login: 3r/min)
- Security headers enforced via Traefik middleware (HSTS, X-Frame-Options, CSP)
- No service exposed directly — all via traefik-public network
- `.env` excluded from version control

## 📊 Monitoring

- **Prometheus** scrapes metrics from all services every 15s with 30-day retention
- **Grafana** auto-provisions Prometheus datasource and Node Exporter dashboard
- **Alertmanager** routes warnings to Slack, criticals to a dedicated channel
- **cAdvisor** provides per-container CPU/memory/network/disk metrics
- **Node Exporter** provides host-level metrics

## 📝 Logging

- **Promtail** scrapes all Docker container logs via Docker socket
- Logs are labeled by container name, service, and compose project
- **Loki** stores logs with 30-day retention and TSDB schema
- Queryable from Grafana using LogQL

## 📦 Requirements

- Docker Engine 24.0+
- Docker Compose v2.20+
- 4GB RAM minimum (8GB recommended)
- Ports 80 and 443 available

## 📦 Changelog

### v1.0.0 (2026-05-01)
- Initial release with traefik, monitoring, webstack, and logging stacks
- Full Prometheus alerting with Slack integration
- Loki + Promtail centralized logging
- Automated volume backup script
