# outputs.tf

output "public_ip" {
  description = "Endereço de IP publico da instancia EC2"
  value       = aws_instance.web_server.public_ip
}