#!/bin/bash

# sudo apt-get remove nodejs
# sudo apt-get remove libnode72 -y
# sudo apt-get install -f

# # Add the NodeSource PPA (for the latest stable version)
# curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# sudo apt-get update
# sudo apt-get install -y unzip
# sudo apt-get install -y nodejs
# sudo apt-get install -y npm
echo "Setting up the application in the custom image..."

echo "Creating group and user..."
sudo groupadd -r csye6225
sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225


echo "Setting up application directory..."
sudo mkdir -p /opt/webapp
sudo cp /tmp/webapp.zip /opt/
sudo unzip /opt/webapp.zip -d /opt/webapp
cd /opt/webapp 
sudo chown -R csye6225:csye6225 /opt/webapp
sudo chmod -R 755 /opt/webapp

echo "Installing dotenv..."
sudo npm install dotenv --save
echo "Setting up environment variables..."
sudo cp /tmp/.env /opt/webapp

echo "Configuring systemd service..."
sudo cp /tmp/webapp.service /etc/systemd/system/

sudo mkdir -p /opt/webapp/logs
sudo chown -R csye6225:csye6225 /opt/webapp/logs
sudo mv /tmp/cloudwatch_config.json /opt/cloudwatch_config.json
sudo chown -R csye6225:csye6225 /opt/cloudwatch_config.json

sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp