# Documentation: https://developer.hashicorp.com/terraform/language/backend/s3

resource "aws_s3_bucket" "terraform_state_securesight" {
  bucket        = "s3-bucket-securesight"
}

# Enabling versioning 
resource "aws_s3_bucket_versioning" "s3_versioning" {
  bucket = aws_s3_bucket.terraform_state_securesight.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_encryption" {
  bucket = aws_s3_bucket.terraform_state_securesight.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access 
resource "aws_s3_bucket_public_access_block" "s3_public_access_block" {
  bucket = aws_s3_bucket.terraform_state_securesight.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

terraform {
  backend "s3" {
    bucket         = "s3-bucket-securesight"
    key            = "terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
    use_lockfile   = true
  }
}
