variable "bucket_name" {
    description  = "The name of the S3 bucket. Must be globally unique."
    type         = string
    default      = "terraform-7up-and-running-backend-state"
}

variable "table_name" {
    description  = "The name of the DynamoDB table. Must be unique in this AWS account."
    type         = string 
    default      = "terraform-up-and-running-locks"
}