
resource "aws_lb" "crate_lb" {
  name               = "crate-internal-lb"
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.private_crate_vpc_subnets.ids
  security_groups    = [aws_security_group.crate_lb_sg.id]
  internal           = true
  tags = {
    Name = "crate-lb-asg"
  }
}

resource "aws_lb_listener_rule" "crate_lb_rule" {
  listener_arn = aws_lb_listener.crate_lb_listner.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = var.target_group.arn
  }
}

resource "aws_lb_listener" "crate_lb_listner" {
  load_balancer_arn = aws_lb.crate_lb.arn
  port              = var.external_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "crate_lb_sg" {
  name   = "crate-lb-sg"
  vpc_id = data.aws_vpc.crate_vpc.id
  ingress {
    from_port   = var.external_port
    to_port     = var.external_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "crate-lb-sg"
  }

}
