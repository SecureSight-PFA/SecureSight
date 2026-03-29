# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_network_address_usage_metrics-1 
# & https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  tags = {
    Name               = var.vpc_name
  }
  enable_dns_support   = true
  enable_dns_hostnames = true

}