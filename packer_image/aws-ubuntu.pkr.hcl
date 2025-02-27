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

variable "artifact_path" {
  type    = string
  default = "build/webapp.zip"
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
  ami_name      = "webapp-${formatdate("20060102-150405", timestamp())}-${uuidv4()}"
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
  image_name   = "webapp-${formatdate("20060102-150405", timestamp())}-${uuidv4()}"
  source_image = "ubuntu-2204-jammy-v20250219"
  zone         = var.gcp_zone
  machine_type = "e2-medium"
  ssh_username = var.ssh_username
  tags         = ["packer-image"]
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.gcp_ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "sudo groupadd csye6225 || true",
      "sudo useradd -r -s /usr/sbin/nologin -g csye6225 csye6225",
      "sudo mkdir -p /opt/webapp",
      "sudo chown -R csye6225:csye6225 /opt/webapp",
      "sudo chmod 755 /opt/webapp"
    ]
  }

  provisioner "file" {
    source      = var.artifact_path
    destination = "/tmp/webapp.zip"
  }

  provisioner "file" {
    source      = "packer_image/mysql_packer.sh"
    destination = "/tmp/mysql_packer.sh"
  }

  provisioner "shell" {
    inline = [
      "sudo chmod +x /tmp/mysql_packer.sh",
      "sudo /tmp/mysql_packer.sh"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo unzip /tmp/webapp.zip -d /opt/webapp/",
      "sudo chown -R csye6225:csye6225 /opt/webapp",
      "sudo chmod -R 755 /opt/webapp",
      "sudo cp /opt/webapp/service/webapp.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable webapp",
      "sudo systemctl start webapp"
    ]
  }
}
