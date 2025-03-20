terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.20.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Check if bucket already exists
data "aws_s3_bucket" "existing" {
  bucket = "tfstatepav"
}

resource "aws_s3_bucket" "terraform-state" {
  count  = data.aws_s3_bucket.existing.id == "" ? 1 : 0
  bucket = "tfstatepav"
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = "tfstatepav"

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = "tfstatepav"
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.ownership]
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = "tfstatepav"
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = "tfstatepav"
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_public_access_block" "block-public-access" {
  bucket = "tfstatepav"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "s3_bucket_name" {
  value = "tfstatepav"
}
