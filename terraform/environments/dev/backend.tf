terraform {
  backend "s3" {
    bucket       = "s3-bucket-securesight-dev"
    key          = "securesight-dev/statefile/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
  }
}