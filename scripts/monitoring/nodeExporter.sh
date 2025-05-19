#!/bin/bash

# Exit on error
set -e

VERSION="1.6.1"
USER="node_exporter"
GROUP="node_exporter"
BINARY_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/node_exporter.service"

echo "🚀 Installing Node Exporter v$VERSION..."

# Create system user for Node Exporter
echo "👤 Creating node_exporter user..."
sudo useradd --system --no-create-home --shell /bin/false $USER || true

# Download Node Exporter
echo "⬇️ Downloading Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz

# Extract and install
echo "📦 Extracting Node Exporter..."
tar -xvf node_exporter-$VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$VERSION.linux-amd64/node_exporter $BINARY_DIR/

# Clean up
echo "🧹 Cleaning up..."
rm -rf node_exporter-$VERSION.linux-amd64*
    
# Create systemd service file
echo "📝 Creating systemd service file for Node Exporter..."
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Node Exporter
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
ExecStart=$BINARY_DIR/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Node Exporter
echo "🔄 Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "✅ Enabling and starting Node Exporter..."
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Status
echo "📡 Checking Node Exporter status..."
sudo systemctl status node_exporter --no-pager

echo "✅ Node Exporter installation complete."
echo "🌐 Metrics available at: http://<your-server-ip>:9100/metrics"
