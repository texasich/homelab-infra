output "server_ips" {
  description = "Private IPs of server nodes"
  value       = aws_instance.server[*].private_ip
}

output "agent_ips" {
  description = "Private IPs of agent nodes"
  value       = aws_instance.agent[*].private_ip
}

output "security_group_id" {
  description = "Security group ID for the k3s cluster"
  value       = aws_security_group.k3s.id
}

output "server_instance_ids" {
  description = "Instance IDs of server nodes"
  value       = aws_instance.server[*].id
}
