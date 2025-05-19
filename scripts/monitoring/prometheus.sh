#!/bin/bash

# Exit on error
set -e

PROM_VERSION="2.47.1"
USER="prometheus"
GROUP="prometheus"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/data"
SERVICE_FILE="/etc/systemd/system/prometheus.service"

echo "🚀 Installing Prometheus v$PROM_VERSION..."

# Create Prometheus user and group
echo "👤 Creating prometheus user..."
sudo useradd --system --no-create-home --shell /bin/false $USER || true

# Download and extract Prometheus
echo "⬇️ Downloading Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v$PROM_VERSION/prometheus-$PROM_VERSION.linux-amd64.tar.gz

echo "📦 Extracting Prometheus..."
tar -xvf prometheus-$PROM_VERSION.linux-amd64.tar.gz
cd prometheus-$PROM_VERSION.linux-amd64

# Create config and data directories
echo "📁 Setting up directories..."
sudo mkdir -p $CONFIG_DIR $DATA_DIR

# Move binaries and config
echo "🚚 Moving binaries and configuration files..."
sudo mv prometheus promtool $INSTALL_DIR/
sudo mv consoles/ console_libraries/ $CONFIG_DIR/
sudo mv prometheus.yml $CONFIG_DIR/

# Set permissions
echo "🔒 Setting permissions..."
sudo chown -R $USER:$GROUP $CONFIG_DIR $DATA_DIR

# Create Prometheus systemd service
echo "📝 Creating systemd service file..."
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=$USER
Group=$GROUP
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=$INSTALL_DIR/prometheus \\
  --config.file=$CONFIG_DIR/prometheus.yml \\
  --storage.tsdb.path=$DATA_DIR \\
  --web.console.templates=$CONFIG_DIR/consoles \\
  --web.console.libraries=$CONFIG_DIR/console_libraries \\
  --web.listen-address=0.0.0.0:9090 \\
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Prometheus
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "✅ Enabling and starting Prometheus..."
sudo systemctl enable prometheus
sudo systemctl start prometheus

echo "📡 Checking Prometheus status..."
sudo systemctl status prometheus --no-pager

echo "✅ Prometheus installation complete."
echo "🌐 Access Prometheus at: http://<your-server-ip>:9090"
