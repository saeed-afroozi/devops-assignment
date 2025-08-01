output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "task1_alb_dns_name" {
  value = aws_lb.task1.dns_name
}

output "task2_alb_dns_name" {
  value = aws_lb.task2.dns_name
}

output "task2_asg_name" {
  value = aws_autoscaling_group.task2.name
} 