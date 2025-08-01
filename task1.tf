resource "aws_instance" "task1" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Task 1!</h1>" > /var/www/html/index.html
              EOF
  tags = {
    Name = "task1-ec2"
  }
}

resource "aws_lb" "task1" {
  name               = "task1-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public.id]
  tags = {
    Name = "task1-alb"
  }
}

resource "aws_lb_target_group" "task1" {
  name     = "task1-tg"
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
    Name = "task1-tg"
  }
}

resource "aws_lb_target_group_attachment" "task1" {
  target_group_arn = aws_lb_target_group.task1.arn
  target_id        = aws_instance.task1.id
  port             = 80
}

resource "aws_lb_listener" "task1" {
  load_balancer_arn = aws_lb.task1.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.task1.arn
  }
} 