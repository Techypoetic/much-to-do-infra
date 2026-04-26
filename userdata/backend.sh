#!/bin/bash
set -e
exec > /var/log/userdata.log 2>&1  # Log userdata itself for debugging

# ── 1. System packages ──────────────────────────────────────────────────────
dnf update -y
dnf install -y git amazon-cloudwatch-agent

# Install Go 1.22
curl -LO https://go.dev/dl/go1.22.4.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile.d/go.sh
export PATH=$PATH:/usr/local/go/bin

# ── 2. App setup ─────────────────────────────────────────────────────────────
useradd -r -s /sbin/nologin appuser
mkdir -p /opt/much-to-do
chown appuser:appuser /opt/much-to-do

cd /opt/much-to-do
git clone -b main https://github.com/Techypoetic/much-to-do.git .

cd Server/MuchToDo
export GOPATH=/root/go
export GOMODCACHE=/root/go/pkg/mod
export GOCACHE=/root/.cache/go-build
/usr/local/go/bin/go build -buildvcs=false -o much-to-do-server ./cmd/api
chown appuser:appuser much-to-do-server

# ── 3. Environment file ──────────────────────────────────────────────────────
cat > /opt/much-to-do/Server/.env << ENVFILE
PORT=8080
MONGODB_URI=mongodb://${db_username}:${db_password}@${mongodb_host}:27017/muchtodo?authSource=admin
REDIS_HOST=${redis_host}
REDIS_PORT=6379
ENVFILE

chmod 600 /opt/much-to-do/Server/.env
chown appuser:appuser /opt/much-to-do/Server/.env

# ── 4. Log file ──────────────────────────────────────────────────────────────
touch /var/log/much-to-do.log
chown appuser:appuser /var/log/much-to-do.log

# ── 5. systemd service ───────────────────────────────────────────────────────
cat > /etc/systemd/system/much-to-do.service << 'SERVICE'
[Unit]
Description=Much-To-Do Backend API
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/much-to-do/Server/MuchToDo
EnvironmentFile=/opt/much-to-do/Server/.env
ExecStart=/opt/much-to-do/Server/MuchToDo/much-to-do-server
Restart=always
RestartSec=5
StandardOutput=append:/var/log/much-to-do.log
StandardError=append:/var/log/much-to-do.log

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable much-to-do
systemctl start much-to-do

# ── 6. CloudWatch Agent ───────────────────────────────────────────────────────
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'CW'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/much-to-do.log",
            "log_group_name": "/much-to-do/backend",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    },
    "force_flush_interval": 15
  }
}
CW

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "Userdata complete."
