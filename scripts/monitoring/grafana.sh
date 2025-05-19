#!/bin/bash

# Exit on any error
set -e

echo "🚀 Starting Grafana installation..."

# Step 1: Install dependencies
echo "📦 Installing dependencies..."
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget

# Step 2: Add the GPG key
echo "🔑 Adding Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Step 3: Add Grafana repository
echo "📝 Adding Grafana APT repository..."
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Step 4: Update and install Grafana
echo "⬇️ Installing Grafana..."
sudo apt-get update
sudo apt-get install -y grafana

# Step 5: Enable and start Grafana service
echo "✅ Enabling Grafana to start on boot..."
sudo systemctl enable grafana-server

echo "🚀 Starting Grafana service..."
sudo systemctl start grafana-server

# Step 6: Check Grafana service status
echo "📡 Checking Grafana service status..."
sudo systemctl status grafana-server --no-pager

echo "✅ Grafana installation completed successfully."
echo "🌐 Access Grafana at: http://<your-server-ip>:3000"
echo "🔐 Default login -> user: admin | password: admin"
