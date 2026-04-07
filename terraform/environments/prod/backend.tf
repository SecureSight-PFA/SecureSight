terraform {
  backend "s3" {
    bucket         = "s3-bucket-securesight"
    key            = "securesight/prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
    use_lockfile   = true
  }
}