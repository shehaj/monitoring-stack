# 🚀 Complete Setup: Secure Monitoring Stack for Dokku Server

This guide walks you through setting up a secure, minimal, and reusable monitoring + logging infrastructure for your Dokku server using:

- Prometheus (metrics)
- Grafana (dashboards + alerts)
- Loki (centralized logs)
- Promtail (log collector)
- cAdvisor (Docker/container stats)
- Node Exporter (system stats)
- Caddy (reverse proxy + HTTPS + Basic Auth)

---

## 🔄 Workflow Overview

1. Build everything **locally** in a structured project folder
2. Push it to **GitHub**
3. SSH into your Dokku server and **clone the repo**
4. Start the monitoring stack via Docker Compose

---

## 🌟 Local Project Structure

```
monitoring-stack/
├── docker-compose.yml
├── .env               # secrets (gitignored)
├── deploy.sh          # optional redeploy script
├── Caddyfile          # reverse proxy config
├── prometheus/
│   └── prometheus.yml
├── loki/
│   └── config.yaml
├── promtail/
│   └── config.yaml
└── README.md
```

---

## 🧪 Setup Instructions (README.md)

### ✅ Prerequisites

- A Linux server (e.g., Dokku, Ubuntu)
- Docker and Docker Compose installed
- Root access to your server
- Caddy installed for reverse proxying
- Domain: `DOMAIN` with the following subdomains pointing to your server IP:
  - `grafana.{$DOMAIN}`
  - `prometheus.{$DOMAIN}`
  - `loki.{$DOMAIN}`

### 🔧 Local Setup

1. Clone this repo:
   ```bash
   git clone https://github.com/YOUR_USERNAME/monitoring-stack.git
   cd monitoring-stack
   ```

2. Create the `.env` file:
   ```dotenv
   GF_SECURITY_ADMIN_PASSWORD=SuperSecurePassword123
   CADDY_AUTH_HASH=JDJhJDE2JHVtd1U3ZmNydVZqS0FTMW...
   ```
   > Generate Caddy password hash with: `caddy hash-password --plaintext 'yourpassword'`

3. Commit everything **except** `.env` (add to `.gitignore`):
   ```bash
   git add .
   git commit -m "Initial monitoring stack"
   git push origin main
   ```

### 🚀 Server Deployment

1. SSH into your server:
   ```bash
   ssh root@YOUR_SERVER_IP
   ```

2. Clone your repo:
   ```bash
   cd /opt
   git clone https://github.com/YOUR_USERNAME/monitoring-stack.git monitoring
   cd monitoring
   ```

3. Add your `.env` file manually (do **not** push it to GitHub).

4. Start the monitoring stack:
   ```bash
   docker compose up -d
   ```

5. Configure Caddy:
   - Copy `Caddyfile` to `/etc/caddy/Caddyfile`
   - Reload Caddy:
     ```bash
     systemctl restart caddy
     ```

6. Visit your monitoring interfaces:
   - [https://grafana.{$DOMAIN}](https://grafana.{$DOMAIN})
   - [https://prometheus.{$DOMAIN}](https://prometheus.{$DOMAIN})
   - [https://loki.{$DOMAIN}](https://loki.{$DOMAIN})

### 🔁 Updating the Stack

If you change configs or update containers:
```bash
./deploy.sh
```

### 🔒 Firewall (UFW) Configuration
```bash
ufw allow 22
ufw allow 80
ufw allow 443
ufw deny 3000 9090 3100
ufw enable
```

---

## 📅 Maintenance

- To add more logs, extend `promtail/config.yaml`
- Grafana admin password is set in `.env`
- Back up `grafana-storage` volume for dashboard persistence

---