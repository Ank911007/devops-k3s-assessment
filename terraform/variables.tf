# terraform/variables.tf
variable "aws_region" {
  description = "AWS region"
  default     = "ap-south-1"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "ubuntu_ami" {
  description = "Ubuntu 24.04 LTS AMI ID"
  type        = string
}
