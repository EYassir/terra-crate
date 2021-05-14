data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  #   vars = {
  #     private_git = jsondecode(data.aws_secretsmanager_secret_version.git_key.secret_string)["asg_git_key"]
  #   }
}

resource "aws_iam_policy" "cratedb_node_policy" {
  name = "cratedb_node_policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [ "logs:*",
                        "s3:*",
                        "ec2:*",
                        "ssm:*",
                        "ssmmessages:*",
                        "ec2messages:*"],
            "Resource": "*"
        }
    ]
}
EOF
}

#Create IAM ROLE
resource "aws_iam_role" "cratedb_node_role" {
  name = "cratedb_node_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
                 
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  permissions_boundary = aws_iam_policy.cratedb_node_policy.arn #"arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/cwagent_policy_myapp"

  tags = {
    tag-key = "cratedb"
  }
}
resource "aws_iam_policy_attachment" "test_attach" {
  name       = "test-attachment"
  roles      = [aws_iam_role.cratedb_node_role.name]
  policy_arn = aws_iam_policy.cratedb_node_policy.arn
}

resource "aws_iam_instance_profile" "cwagtn_profile" {
  name = "test_profile"
  role = aws_iam_role.cratedb_node_role.name
}


#Create lanch configuration
resource "aws_launch_configuration" "crate_lc" {
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = "t3.medium"
  security_groups      = [aws_security_group.allow_cratedb_port.id]
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.cwagtn_profile.name
  user_data            = data.template_file.user_data.rendered

}

resource "aws_key_pair" "my_awsome_keypair" {
  key_name   = var.key_name
  public_key = var.key_value
}

#Create Security Group for ec2 instance
resource "aws_security_group" "allow_cratedb_port" {
  name   = "crate-nodes-sg"
  vpc_id = data.aws_vpc.crate_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.dashboard_port
    to_port     = var.dashboard_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.node_port
    to_port     = var.node_port
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
    Name = "allow_cratedb_port"
  }

}

#Create autoscaling group
resource "aws_autoscaling_group" "crate_node_asg" {
  name                      = "crate-node-asg"
  launch_configuration      = aws_launch_configuration.crate_lc.name
  min_size                  = 4
  max_size                  = 15
  health_check_grace_period = 180
  health_check_type         = "ELB"
  desired_capacity          = 4
  target_group_arns         = [aws_lb_target_group.crate_nodes_tg.arn]
  vpc_zone_identifier       = data.aws_subnet_ids.crate_vpc_subnets_ids.ids

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "crate_node_from_asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = "cratedb"
    propagate_at_launch = true
  }

}

#Create target group
resource "aws_lb_target_group" "crate_nodes_tg" {
  name     = "crate-nodes-tg"
  port     = var.dashboard_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.crate_vpc.id
  health_check {
    enabled             = true
    interval            = 180
    path                = "/"
    port                = var.dashboard_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = 200
  }
}


resource "aws_autoscaling_policy" "crate_node_asg_policy" {
  name                      = "cpu_60"
  policy_type               = "TargetTrackingScaling"
  adjustment_type           = "ChangeInCapacity"
  estimated_instance_warmup = 180

  autoscaling_group_name = aws_autoscaling_group.crate_node_asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

