resource "aws_security_group" "internal_lb_sg" {
  name        = "app-internal-lb-sg"
  description = "Allow traffic from Public Subnet to Internal LB"
  vpc_id      = module.vpc.vpc_id

  # Inbound Rule: HTTP
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    # BEST PRACTICE: Reference the SG of your public instances
    security_groups = [aws_security_group.public_instance_sg.id]
  }

  # Inbound Rule: HTTPS
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.public_instance_sg.id]
  }

  # Outbound: Allow LB to talk to your App Instances
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 1. The Application Load Balancer
resource "aws_lb" "internal_alb" {
  name               = "app-internal-lb"
  internal           = true # CRITICAL: This makes it internal
  load_balancer_type = "application"
  
  # The LB needs to sit in the subnets where it will receive/route traffic
  subnets            = module.vpc.private_subnets
  security_groups    = [aws_security_group.internal_lb_sg.id]

  tags = {
    Name = "InternalALB"
  }
}

# 2. The Target Group
# This is what your ASG will point to later
resource "aws_lb_target_group" "app_tg" {
  name     = "app-target-group"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/" # Make sure your app has a route here
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }
}

# 3. The Listener
# This tells the LB to forward traffic from Port 80 to your Target Group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

output "internal_lb_dns" {
  value = aws_lb.internal_alb.dns_name
}