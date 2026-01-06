# terraform/main.tf
provider "aws" {
  region = var.aws_region
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Use default subnet
data "aws_subnet" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Security Group for SSH
resource "aws_security_group" "ssh_sg" {
  name   = "ssh-access"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
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

# Ubuntu 24.04 EC2 Instance
resource "aws_instance" "ubuntu_server" {
  ami           = var.ubuntu_ami
  instance_type = "t2.medium"
  key_name      = var.key_name
  subnet_id     = data.aws_subnet.default.id

  vpc_security_group_ids = [aws_security_group.ssh_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "ubuntu-24-ec2"
  }
}
