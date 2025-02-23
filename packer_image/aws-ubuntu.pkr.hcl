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

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "Rugved_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  instance_type = "${var.aws_instance_type}"
  region = "${var.aws_region}"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  access_key   = "${var.aws_access_id}"
  secret_key   = "${var.aws_access_key}"
  ssh_username = "${var.ssh_username}"

}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    script = "./mysql_packer.sh"
  }
}