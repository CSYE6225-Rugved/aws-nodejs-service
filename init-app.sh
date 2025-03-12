#!/bin/bash

sudo apt-get update
sudo apt-get install -y unzip
sudo apt-get install -y nodejs
sudo apt-get install -y npm
echo "Setting up the application in the custom image..."
echo "Creating group and user..."

sudo groupadd -r csye6225
sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225

echo "Updating MySQL root password..."
export MYSQL_PWD=""
sudo mysql --user=root --password=""<<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

echo "Restarting MySQL..."
sudo systemctl restart mysql

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

sudo systemctl daemon-reload
sudo systemctl enable webapp
sudo systemctl start webapp