#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Creating non-login user and group..."
sudo groupadd -r csye6225 || true
sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225

echo "Setting up application directory..."
sudo mkdir -p /opt/webapp
sudo chown -R csye6225:csye6225 /opt/webapp

echo "Ensuring webapp.zip exists..."
if [ ! -f /tmp/webapp.zip ]; then
    echo "Error: /tmp/webapp.zip not found. Exiting."
    exit 1
fi

echo "Copying application files..."
sudo cp /tmp/webapp.zip /opt/webapp/
sudo apt-get install -y unzip
sudo unzip /opt/webapp/webapp.zip -d /opt/webapp/
sudo chown -R csye6225:csye6225 /opt/webapp

echo "Configuring systemd service..."
if [ ! -f /tmp/webapp.service ]; then
    echo "Error: /tmp/webapp.service not found. Exiting."
    exit 1
fi
sudo cp /tmp/webapp.service /etc/systemd/system/webapp.service
sudo systemctl daemon-reload
sudo systemctl enable webapp

echo "Custom image setup completed successfully."
