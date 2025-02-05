#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update package lists and upgrade packages
sudo apt update
sudo apt upgrade -y

# Install MySQL
sudo apt install mysql-server -y

# Start MySQL service
sudo systemctl start mysql
sudo systemctl enable mysql

# Create database for the application
sudo mysql -e "CREATE DATABASE HealthCheck;"

# Create new Linux group for the application
sudo groupadd healthCheck_group

# Create new user for the application and add to the group
sudo useradd -m -g healthCheck_group healthCheck_user

# Install unzip if not already installed
sudo apt install unzip -y

# Create directory for the application
sudo mkdir -p /opt/csye6225

# unzip the application
sudo unzip /tmp/healthcheck_app.zip -d /opt/csye6225

# Update permissions
sudo chown -R healthCheck_user:healthCheck_group /opt/csye6225
sudo chmod -R 755 /opt/csye6225