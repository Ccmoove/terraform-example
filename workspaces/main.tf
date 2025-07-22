terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-7up-and-running-backend-state"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0b86aaed8ef90e45f" # Make sure this AMI exists in us-east-1
  instance_type = terraform.workspace == "default" ? "t2.medium" : "t2.micro"
}
