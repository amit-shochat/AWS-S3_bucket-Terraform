

output "id" {
  description = "List of IDs of instances"
  value       = aws_instance.centos.id
}

output "instance_name" {
  value       = var.instance_name
}
output "ip" {
  value       = aws_eip.ip-im-alive-env.public_ip
}