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
sudo systemctl enable mysql || echo "Warning: MySQL could not be enabled, continuing."

echo "Verifying MySQL service status..."
if systemctl is-active --quiet mysql; then
  echo "MySQL is running successfully."
else
  echo "MySQL installation failed."
  journalctl -u mysql --no-pager | tail -n 50
  exit 1
fi

# echo "Setting MySQL root password and securing installation..."
# sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
# sudo mysql -e "FLUSH PRIVILEGES;"

echo "Creating database and user..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS HealthCheck;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'rugved'@'localhost' IDENTIFIED BY 'admin';"
sudo mysql -e "GRANT ALL PRIVILEGES ON HealthCheck.* TO 'rugved'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "MySQL installation completed successfully!"