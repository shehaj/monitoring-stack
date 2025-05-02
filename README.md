# 🚀 Complete Setup: Secure Monitoring Stack for Dokku Server (System-Wide NGINX)

This guide walks you through setting up a secure, minimal, and reusable monitoring + logging infrastructure for your Dokku server using:

- Prometheus (metrics)
- Grafana (dashboards + alerts)
- Loki (centralized logs)
- Promtail (log collector)
- cAdvisor (Docker/container stats)
- Node Exporter (system stats)
- **System-wide NGINX** (used by both Dokku and your server)

---

## 🔄 Workflow Overview

1. Build everything **locally** in a structured project folder
2. Push it to **GitHub**
3. SSH into your Dokku server and **clone the repo to /opt/monitoring**
4. Start the monitoring stack via Docker Compose
5. Use **system-wide NGINX** to proxy Grafana, Prometheus, Loki

---

## 🌟 Local Project Structure

```
monitoring-stack/
├── docker-compose.yml
├── .env               # secrets (gitignored)
├── deploy.sh          # optional redeploy script
├── nginx-sites/       # NGINX virtual host configs (templated)
│   ├── grafana.conf.template
│   ├── prometheus.conf.template
│   └── loki.conf.template
├── prometheus/
│   └── prometheus.yml
├── loki/
│   └── config.yaml
├── promtail/
│   └── config.yaml
└── README.md
```

---

## 🔧 NGINX Virtual Host Config Templates (nginx-sites/)

Use environment variables to substitute the domain dynamically when generating the actual `.conf` files.

### `grafana.conf.template`
```nginx
server {
    listen 80;
    server_name grafana.${DOMAIN};

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### `prometheus.conf.template`
```nginx
server {
    listen 80;
    server_name prometheus.${DOMAIN};

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://localhost:9090;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### `loki.conf.template`
```nginx
server {
    listen 80;
    server_name loki.${DOMAIN};

    auth_basic "Restricted Access";
    auth_basic_user_file /etc/nginx/.htpasswd;

    location / {
        proxy_pass http://localhost:3100;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 🧪 Setup Instructions (README.md)

### ✅ Prerequisites

- A Linux server with **Dokku installed** (which uses system-wide NGINX)
- Docker and Docker Compose installed
- Root access to your server
- A domain name with the following subdomains pointing to your server IP:
  - `grafana.<your-domain>`
  - `prometheus.<your-domain>`
  - `loki.<your-domain>`

### 🔧 Local Setup

1. Clone this repo:

   ```bash
   git clone git@github.com:YOUR_USERNAME/monitoring-stack.git
   cd monitoring-stack
   ```

2. Create the `.env` file:

   ```dotenv
   GF_SECURITY_ADMIN_PASSWORD=SuperSecurePassword123
   DOMAIN=your.domain
   ```

3. Commit everything **except** `.env` (add to `.gitignore`):

   ```bash
   git add .
   git commit -m "Initial monitoring stack"
   git push origin main
   ```

### 🚀 Server Deployment

1. SSH into your server:

   ```bash
   ssh dev@YOUR_SERVER_IP
   ```

2. Clone your repo into `/opt/monitoring`:

   ```bash
   cd /opt
   sudo git clone git@github.com:YOUR_USERNAME/monitoring-stack.git monitoring
   cd monitoring
   ```

3. Add your `.env` file manually (do **not** push it to GitHub).

4. Rebuild NGINX config files:

   ```bash
   export $(grep -v '^#' .env | xargs)
   envsubst '${DOMAIN}' < nginx-sites/prometheus.conf.template | sudo tee /etc/nginx/sites-available/prometheus.conf > /dev/null
   envsubst '${DOMAIN}' < nginx-sites/loki.conf.template | sudo tee /etc/nginx/sites-available/loki.conf > /dev/null
   envsubst '${DOMAIN}' < nginx-sites/grafana.conf.template | sudo tee /etc/nginx/sites-available/grafana.conf > /dev/null
   ```

5. Enable sites:

   ```bash
   sudo ln -s /etc/nginx/sites-available/grafana.conf /etc/nginx/sites-enabled/
   sudo ln -s /etc/nginx/sites-available/prometheus.conf /etc/nginx/sites-enabled/
   sudo ln -s /etc/nginx/sites-available/loki.conf /etc/nginx/sites-enabled/
   ```

6. Add basic auth (optional):

   ```bash
   sudo apt install apache2-utils
   sudo htpasswd -c /etc/nginx/.htpasswd admin
   ```

7. Reload NGINX:

   ```bash
   sudo systemctl reload nginx
   ```

8. Visit your monitoring interfaces:

   - `https://grafana.<your-domain>`
   - `https://prometheus.<your-domain>`
   - `https://loki.<your-domain>`

### 🔄 Updating the Stack

If you change configs or update containers:

```bash
./deploy.sh
```

### 🔒 Firewall (UFW) Configuration

```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw deny 3000 9090 3100
sudo ufw enable
```

---

## 🗓️ Maintenance

- To add more logs, extend `promtail/config.yaml`
- Grafana admin password is set in `.env`
- Back up `grafana-storage` volume for dashboard persistence

---

Let me know if you'd like a `.zip` version of this stack.