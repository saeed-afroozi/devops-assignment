resource "aws_launch_template" "task2" {
  name_prefix   = "task2-asg-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [aws_security_group.ec2.id]
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Task 2 ASG!</h1>" > /var/www/html/index.html
              EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "task2-asg-instance"
    }
  }
}

resource "aws_lb" "task2" {
  name               = "task2-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id]
  tags = {
    Name = "task2-alb"
  }
}

resource "aws_lb_target_group" "task2" {
  name     = "task2-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  tags = {
    Name = "task2-tg"
  }
}

resource "aws_lb_listener" "task2" {
  load_balancer_arn = aws_lb.task2.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task2.arn
  }
}

resource "aws_autoscaling_group" "task2" {
  name                = "task2-asg"
  desired_capacity    = var.asg_desired_capacity
  max_size            = var.asg_max_size
  min_size            = var.asg_min_size
  target_group_arns   = [aws_lb_target_group.task2.arn]
  vpc_zone_identifier = [aws_subnet.private.id]
  launch_template {
    id      = aws_launch_template.task2.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "task2-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "task2_scale_up" {
  name                   = "task2-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.task2.name
}

resource "aws_autoscaling_policy" "task2_scale_down" {
  name                   = "task2-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.task2.name
}

resource "aws_cloudwatch_metric_alarm" "task2_high_cpu" {
  alarm_name          = "task2-high-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_in_threshold
  alarm_description   = "Scale IN if CPU utilization is above threshold"
  alarm_actions       = [aws_autoscaling_policy.task2_scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.task2.name
  }
}

resource "aws_cloudwatch_metric_alarm" "task2_low_cpu" {
  alarm_name          = "task2-low-cpu-utilization"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = var.scale_out_threshold
  alarm_description   = "Scale OUT if CPU utilization is below threshold"
  alarm_actions       = [aws_autoscaling_policy.task2_scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.task2.name
  }
} 