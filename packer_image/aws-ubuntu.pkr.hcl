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
  source_image = "ubuntu-2204-jammy-v20250219"
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

  provisioner "file" {
    source      = "webapp.zip" # Ensure this file is generated in GitHub Actions before being uploaded
    destination = "/tmp/webapp.zip"
  }

  provisioner "file" {
    source      = "service/webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "shell" {
    inline = [
      "echo 'Creating csye6225 user...'",
      "sudo groupadd -r csye6225 || true",
      "sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225",

      "echo 'Setting up application directory...'",
      "sudo mkdir -p /opt/webapp",
      "sudo chown -R csye6225:csye6225 /opt/webapp",

      "echo 'Copying application files...'",
      "sudo cp /tmp/webapp.zip /opt/webapp/",
      "sudo apt-get install -y unzip",
      "sudo unzip /opt/webapp/webapp.zip -d /opt/webapp/",
      "sudo chown -R csye6225:csye6225 /opt/webapp",

      "echo 'Configuring systemd service...'",
      "sudo cp /tmp/webapp.service /etc/systemd/system/webapp.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp"
    ]
  }
}
