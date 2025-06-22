provider "aws" {
    region = "us-east-1"
}

    resource "aws_iam_role" "ec2_role" {
      name = "EC2Role"
      assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Principal = {
              Service = "ec2.amazonaws.com"
            }
            Action = "sts:AssumeRole"
          }
        ]
      })
    }

    resource "aws_iam_policy" "ec2_policy" {
      name        = "EC2CreationPolicy"
      description = "IAM policy for creating EC2 instances"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "ec2:RunInstances",
              "ec2:CreateTags",
              "ec2:DescribeImages",
              "ec2:DescribeInstanceStatus",
              "ec2:DescribeSubnets",
              "ec2:DescribeAvailabilityZones",
              "ec2:DescribeSecurityGroups",
              "ec2:DescribeKeyPairs",
              "ec2:DescribeRegions"
            ]
            Resource = "*"
          }
        ]
      })
    }

resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_launch_template" "foobar" {
  name_prefix = "foobar"
  image_id = "ami-0f214d1b3d031dc53"
  instance_type = "t2.micro"

  lifecycle  {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  vpc_zone_identifier   = data.aws_subnets.default.ids 
 
 target_group_arns = [aws_lb_target_group.asg.arn]
 health_check_type = "ELB"

  min_size = 2
  max_size = 10
  
  tag {
      key                 = "Name"
      value               = "terraform-asg-example"
      propagate_at_launch = true
  }    

launch_template {
    id        = aws_launch_template.foobar.id      

  }
}

data "aws_vpc" "default" {
  default = true

  }

data "aws_subnets" "default" {
  filter { 
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "instance" {
  name = var.instance_security_group_name

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 

resource "aws_lb" "example" {

  name          = var.alb_name

  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}
 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }

  }
}

resource "aws_security_group" "alb" {

  name = var.alb_security_group_name

  # Allow inbound HTTP requests
  ingress {
    from_port = 80
    to_port   = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_lb_target_group" "asg" {
  
  name  = var.alb_name
  
  port  = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type =  "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
