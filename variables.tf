variable "region" {
  description = "The region the tf runs in"
  type        = string
  default     = "eu-west-2"
}

variable "sse_algorithm" {
  description = "The default algorithm used to encrypt the S3 bucket"
  type        = string
  default     = "AES256"
}