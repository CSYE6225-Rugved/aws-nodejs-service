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


packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
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

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
  ]
  provisioner "file" {
    source      = "webapp.zip"
    destination = "/tmp/webapp.zip"
  }
  provisioner "file" {
    source      = ".env"
    destination = "/tmp/.env"
  }
  provisioner "file" {
    source      = "webapp.service"
    destination = "/tmp/webapp.service"
  }

  provisioner "shell" {
    script = "init-app.sh"
  }
}