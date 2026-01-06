# terraform/outputs.tf
output "instance_public_ip" {
  value = aws_instance.ubuntu_server.public_ip
}

output "ssh_command" {
  value = "ssh -i <your-key.pem> ubuntu@${aws_instance.ubuntu_server.public_ip}"
}
