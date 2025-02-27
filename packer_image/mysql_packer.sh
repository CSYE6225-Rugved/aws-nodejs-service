#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Add MySQL APT GPG Key
sudo mkdir -p /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/mysql.gpg https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
sudo chmod 644 /etc/apt/keyrings/mysql.gpg

# Add MySQL Repository
echo "deb [signed-by=/etc/apt/keyrings/mysql.gpg] http://repo.mysql.com/apt/ubuntu jammy mysql-8.0" | sudo tee /etc/apt/sources.list.d/mysql.list

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

echo "Setting up the application in the custom image..."
echo "Creating group and user..."
sudo apt-get install -y npm
sudo apt-get install -y nodejs
sudo groupadd -r csye6225 || true
sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225

echo "Setting up application directory..."
sudo mkdir -p /opt/webapp
sudo chown -R csye6225:csye6225 /opt/webapp

# Ensure the webapp.zip file is available in the correct location
if [ -f /tmp/webapp.zip ]; then
    sudo cp /tmp/webapp.zip /opt/webapp/
else
    echo "Error: /tmp/webapp.zip not found."
    exit 1
fi

sudo apt-get install -y unzip
sudo unzip /opt/webapp/webapp.zip -d /opt/webapp/

echo "Configuring systemd service..."
# Ensure the webapp.service file is available in the correct location
if [ -f service/webapp.service ]; then
    sudo cp service/webapp.service /etc/systemd/system/
else
    echo "Error: service/webapp.service not found."
    exit 1
fi

sudo systemctl daemon-reload
sudo systemctl enable webapp