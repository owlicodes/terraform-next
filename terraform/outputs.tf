# Outputs
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "instance_public_ips" {
  value = aws_instance.nextjs_app[*].public_ip
}

output "alb_dns_name" {
  value = aws_lb.nextjs_alb.dns_name
}