#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo "Updating package lists..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Fixing broken dependencies..."
sudo apt-get install -f -y
sudo dpkg --configure -a

echo "Removing any existing MySQL installation..."
sudo apt-get remove --purge -y mysql-server mysql-client mysql-common
sudo apt-get autoremove -y
sudo apt-get autoclean

echo "Adding MySQL official APT repository..."
sudo mkdir -p /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/mysql.gpg
curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | sudo tee /etc/apt/keyrings/mysql.gpg > /dev/null
echo 'deb [signed-by=/etc/apt/keyrings/mysql.gpg] http://repo.mysql.com/apt/ubuntu jammy mysql-8.0' | sudo tee /etc/apt/sources.list.d/mysql.list

echo "Updating package lists again..."
sudo apt-get update -y

echo "Installing MySQL Server..."
sudo apt-get install -y mysql-server

echo "Restarting MySQL service..."
sudo systemctl restart mysql || sudo service mysql restart

echo "Enabling MySQL service..."
sudo systemctl enable mysql || echo "⚠️ Warning: MySQL could not be enabled, continuing."

echo "Verifying MySQL service status..."
if systemctl is-active --quiet mysql; then
    echo "MySQL is running successfully."
else
    echo "MySQL installation failed."
    journalctl -u mysql --no-pager | tail -n 50
    exit 1
fi


echo "Creating database and user..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS HealthCheck;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'rugved'@'localhost' IDENTIFIED BY 'admin';"
sudo mysql -e "GRANT ALL PRIVILEGES ON HealthCheck.* TO 'rugved'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "MySQL installation completed successfully!"

echo " Creating csye6225 user and group..."
sudo groupadd -r csye6225 || true
sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225 || true

echo " Creating /opt/webapp directory..."
sudo mkdir -p /opt/webapp
sudo chown -R csye6225:csye6225 /opt/webapp

echo " Moving files to /opt/webapp..."
if [ -f "/tmp/webapp.zip" ]; then
    sudo mv /tmp/webapp.zip /opt/webapp/
    sudo unzip -o /opt/webapp/webapp.zip -d /opt/webapp/
else
    echo "ERROR: /tmp/webapp.zip not found!"
    exit 1
fi

echo " Configuring systemd service..."
if [ -f "/tmp/webapp.service" ]; then
    sudo mv /tmp/webapp.service /etc/systemd/system/webapp.service
    sudo systemctl daemon-reload
    sudo systemctl enable webapp
else
    echo "ERROR: /tmp/webapp.service not found!"
    exit 1
fi

echo "Web application setup completed successfully!"
