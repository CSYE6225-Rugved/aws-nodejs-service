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
  ami_name      = "rugved-${formatdate("20060102-150405", timestamp())}"
  instance_type = var.aws_instance_type
  region        = var.aws_region

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username = var.ssh_username
}

source "googlecompute" "gcp_ubuntu" {
  project_id      = var.gcp_project_id
  image_name      = "custom-ubuntu-gcp-${formatdate("20060102-150405", timestamp())}"
  source_image    = "ubuntu-2404-lts"
  zone            = var.gcp_zone
  machine_type    = "e2-medium"
  ssh_username    = var.ssh_username

  tags = ["packer-image"]
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.googlecompute.gcp_ubuntu"
  ]

  provisioner "shell" {
    script = "./mysql_packer.sh"
  }
}