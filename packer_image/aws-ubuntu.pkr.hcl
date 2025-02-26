variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_username" {
  type    = string
  default = "ubuntu"
}

variable "aws_access_id" {
  type    = string
  default = "AKIAX5ZI6K5ANVXLECUQ"
}

variable "aws_access_key" {
  type    = string
  default = "Xdrm+cMWpHYrytgh8B/BlnzQs8ykrX9yd/MoEOQs"
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

variable "gcp_credentials_file" {
  type    = string
  default = "/Users/rugvedgundawar/Downloads/devproject-452005-0b47c3aa9a73.json"
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
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  access_key   = var.aws_access_id
  secret_key   = var.aws_access_key
  ssh_username = var.ssh_username
}

source "googlecompute" "gcp_ubuntu" {
  project_id      = var.gcp_project_id
  credentials_file = var.gcp_credentials_file
  image_name      = "custom-ubuntu-gcp-${formatdate("20060102-150405", timestamp())}"
  source_image    = "ubuntu-2204-jammy-v20250219"
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
