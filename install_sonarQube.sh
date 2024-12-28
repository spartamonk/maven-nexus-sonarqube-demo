#!/bin/bash

# Exit script on any error
set -e

# Define SonarQube version and paths
SONARQUBE_VERSION="9.9.1.69595"
SONARQUBE_DOWNLOAD_URL="https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONARQUBE_VERSION}.zip"
INSTALL_DIR="/opt/sonarqube"

# Update system packages
sudo apt update -y && sudo apt upgrade -y

# Install dependencies

sudo apt install unzip openjdk-17-jre -y

# Verify Java installationd
java -version

# Create a user for SonarQube
sudo groupadd sonar || true
sudo useradd -r -d $INSTALL_DIR -g sonar -s /bin/bash sonar || true

# Download and extract SonarQube
cd /tmp
curl -v -L $SONARQUBE_DOWNLOAD_URL -o sonarqube.zip
sudo mkdir -p $INSTALL_DIR
sudo unzip sonarqube.zip -d $INSTALL_DIR
sudo mv $INSTALL_DIR/sonarqube-${SONARQUBE_VERSION}/* $INSTALL_DIR

# Set permissions for SonarQube directories
sudo chown -R sonar:sonar $INSTALL_DIR

# Configure SonarQube as a service
cat <<EOL | sudo tee /etc/systemd/system/sonarqube.service
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking
ExecStart=$INSTALL_DIR/bin/linux-x86-64/sonar.sh start
ExecStop=$INSTALL_DIR/bin/linux-x86-64/sonar.sh stop
User=sonar
Group=sonar
LimitNOFILE=65536
LimitNPROC=4096
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOL

# Enable and start SonarQube service
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# Verify SonarQube service status
sudo systemctl status sonarqube
