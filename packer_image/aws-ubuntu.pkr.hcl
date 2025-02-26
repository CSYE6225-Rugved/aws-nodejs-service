variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "aws_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "gcp_project_id" {
  type    = string
  default = "devproject-452005"
}

variable "gcp_zone" {
  type    = string
  default = "us-central1-a"
}

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    googlecompute = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/googlecompute"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "rugved-${formatdate("20060102-150405", timestamp())}-${uuidv4()}"
  instance_type = var.aws_instance_type
  region        = var.aws_region

  source_ami_filter {
  filters = {
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

  ssh_username = var.ssh_username
}

source "googlecompute" "gcp_ubuntu" {
  project_id   = var.gcp_project_id
  image_name   = "rugved-${formatdate("20060102-150405", timestamp())}-${uuidv4()}"
  source_image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-lts"
  zone         = var.gcp_zone
  machine_type = "e2-medium"
  ssh_username = var.ssh_username

  tags = ["packer-image"]
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.gcp_ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",

      "echo 'Updating package lists...'",
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",

      "echo 'Fixing broken dependencies...'",
      "sudo apt-get install -f -y",
      "sudo dpkg --configure -a",

      "echo 'Removing any existing MySQL installation...'",
      "sudo apt-get remove --purge -y mysql-server mysql-client mysql-common",
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",

      "echo 'Adding MySQL official APT repository...'",
      "sudo mkdir -p /etc/apt/keyrings",
      "sudo rm -f /etc/apt/keyrings/mysql.gpg",
      "curl -fsSL https://repo.mysql.com/RPM-GPG-KEY-mysql-2022 | sudo tee /etc/apt/keyrings/mysql.gpg > /dev/null",
      "echo 'deb [signed-by=/etc/apt/keyrings/mysql.gpg] http://repo.mysql.com/apt/ubuntu jammy mysql-8.0' | sudo tee /etc/apt/sources.list.d/mysql.list",

      "echo 'Updating package lists again...'",
      "sudo apt-get update -y",

      "echo 'Installing MySQL Server...'",
      "sudo apt-get install -y mysql-server",

      "echo 'Restarting MySQL service...'",
      "sudo systemctl restart mysql || sudo service mysql restart",

      "echo 'Enabling MySQL service...'",
      "sudo systemctl enable mysql || echo 'Warning: MySQL could not be enabled, continuing.'",

      "echo 'Verifying MySQL service status...'",
      "if systemctl is-active --quiet mysql; then",
      "    echo 'MySQL is running successfully.'",
      "else",
      "    echo 'MySQL installation failed.'",
      "    journalctl -u mysql --no-pager | tail -n 50",
      "    exit 1",
      "fi",

      "echo 'Creating database and user...'",
      "sudo mysql -e \"CREATE DATABASE IF NOT EXISTS HealthCheck;\"",
      "sudo mysql -e \"CREATE USER IF NOT EXISTS 'rugved'@'localhost' IDENTIFIED BY 'admin';\"",
      "sudo mysql -e \"GRANT ALL PRIVILEGES ON HealthCheck.* TO 'rugved'@'localhost';\"",
      "sudo mysql -e \"FLUSH PRIVILEGES;\"",

      "echo 'MySQL installation completed successfully!'"
    ]
  }
}