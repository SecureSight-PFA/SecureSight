terraform {
  backend "s3" {
    bucket         = "s3-bucket-securesight"
    key            = "securesight/statefile/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-lock-securesight"
    encrypt        = true
  }
}