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
  ami           = data.aws_ami.amazon_linux.id # Use the latest Amazon Linux 2 AMI
  instance_type = "t3.large"
  key_name      = aws_key_pair.minecraft_key.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  tags = {
    Name = var.instance_name
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
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