output "ipv4_address" {
  description = "Public IPv4 address of the server."
  value       = gigahost_server.main.srv_primary_ip
}

output "connect_address" {
  description = "host:port for OpenRA's Connect to a server dialog."
  value       = "${gigahost_server.main.srv_primary_ip}:${var.server.listen_port}"
}

output "server_id" {
  description = "Gigahost server id."
  value       = gigahost_server.main.srv_id
}

output "ssh_private_key" {
  description = "Generated OpenSSH private key for root access to the server."
  value       = tls_private_key.main.private_key_openssh
  sensitive   = true
}

output "ssh_command" {
  description = "SSH to the server as root (write ssh_private_key to a file and use ssh -i)."
  value       = "ssh root@${gigahost_server.main.srv_primary_ip}"
}
