terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft_key"
  public_key = tls_private_key.minecraft_key.public_key_openssh
}

resource "tls_private_key" "minecraft_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_instance" "minecraft" {
  ami           = data.aws_ami.amazon_linux.id  # Use the latest Amazon Linux 2023 ARM AMI
  instance_type = "t4g.medium"
  key_name      = aws_key_pair.minecraft_key.key_name

  tags = {
    Name = var.instance_name
  }

  network_interface {
    device_index                = 0
    associate_public_ip_address = true
    security_groups             = [aws_security_group.minecraft_sg.name]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-arm64-gp2"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft_security_group"
  description = "Security group for Minecraft server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  value = aws_instance.minecraft.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.minecraft_key.private_key_pem
  sensitive = true
}
