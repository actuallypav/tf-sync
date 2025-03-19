variable "region" {
  description = "The region the tf runs in"
  type        = string
  default = "eu-west-2"
}

variable "state_bucket_name" {
    description = "The name of the s3 bucket used for storing states"
    type = string
    default = "terraform_state"
}

variable "sse_algorithm" {
    description = "The default algorithm used to encrypt the S3 bucket"
    type = string
    default = "AES256"
}
