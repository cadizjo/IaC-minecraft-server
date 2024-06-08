output "instance_public_ip" {
  value = aws_instance.minecraft.public_ip
}

output "private_key_pem" {
  value     = tls_private_key.minecraft_key.private_key_pem
  sensitive = true
}