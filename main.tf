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

 
resource "aws_instance" "example" {
    ami = "ami-0b86aaed8ef90e45f"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.xhtml
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    user_data_replace_on_change = true

    tags = {
        Name = "terraform-example"
    }
}

resource "aws_default_vpc" "default" {
    tags = {
        Name = "Default VPC"
    } 
} 

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
 }

