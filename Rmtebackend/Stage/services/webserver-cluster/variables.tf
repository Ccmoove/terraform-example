variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "instance_security_group_name" {
  description = "Name for the instance security group"
  type        = string
  default     = "instance-sg"
}

variable "alb_security_group_name" {
  description = "Name for the ALB security group"
  type        = string
  default     = "alb-sg"
}

variable "alb_name" {
  description = "Name for the Application Load Balancer"
  type        = string
  default     = "terraform-alb"
}

variable "db_remote_state_bucket" {
  description = "S3 bucket for remote DB state"
  type        = string
}

variable "db_remote_state_key" {
  description = "Key path for DB remote state in S3"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the ASG"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
  default     = "ami-0f214d1b3d031dc53" # or whatever default you use
}

variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 10
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 2
}




