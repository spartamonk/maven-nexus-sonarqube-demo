#!/bin/bash

# Exit on any error
set -e

# Define Nexus version and installation paths
NEXUS_VERSION="3.75.1-01"
NEXUS_DOWNLOAD_URL="https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz"
INSTALL_DIR="/opt/nexus"
DATA_DIR="/opt/sonatype-work"

# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install Java (required for Nexus Repository)

sudo apt install openjdk-17-jre -y

# Verify Java installation
java -version

# Create Nexus user and group
sudo groupadd nexus || true
sudo useradd -r -d $INSTALL_DIR -g nexus -s /bin/bash nexus || true

# Download and extract Nexus Repository
sudo mkdir -p $INSTALL_DIR
cd /tmp

#wget $NEXUS_DOWNLOAD_URL -o nexus2.tar.gz
sudo curl -v -L $NEXUS_DOWNLOAD_URL -o nexus.tar.gz
sudo tar -xvzf nexus.tar.gz -C $INSTALL_DIR --strip-components=1


# Set permissions for Nexus directories
sudo chown -R nexus:nexus $INSTALL_DIR
sudo mkdir -p $DATA_DIR
sudo chown -R nexus:nexus $DATA_DIR

# Configure Nexus to run as a service
cat <<EOL | sudo tee /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=$INSTALL_DIR/bin/nexus start
ExecStop=$INSTALL_DIR/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Enable Nexus service at boot
sudo systemctl daemon-reload
sudo systemctl enable nexus

# Start Nexus Repository Manager
sudo systemctl start nexus

# Verify Nexus service status
sudo systemctl status nexus


