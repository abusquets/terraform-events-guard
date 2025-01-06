output "instance_ip" {
  description = "Public IP of the Lightsail instance"
  value       = aws_lightsail_static_ip.events_guard_static_ip.ip_address
}