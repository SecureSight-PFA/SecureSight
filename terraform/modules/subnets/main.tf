# Documentation: https://docs.aws.amazon.com/eks/latest/userguide/network-reqs.html 
# & https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

# Private subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "backup1-private-subnet-${count.index + 1}"
    Type = "private"
    "kubernetes.io/role/internal-elb"     = "1"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "backup1-public-subnet-${count.index + 1}"
    Type = "public"
    "kubernetes.io/role/elb"          = "1"

  }
}