resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true  # instances get a public ip automatically
 
  tags = merge({
    Name = "public-subnet-${count.index}-${var.environment}"
    "kubernetes.io/role/elb"                    = "1"               
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }, var.tags)
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = var.vpc_id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge({
    Name = "private-subnet-${count.index}-${var.environment}"
    "kubernetes.io/role/internal-elb"           = "1"                  # ← ADD (for internal ALBs)
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"  
  }, var.tags)
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name = "nat-eip-${var.environment}"
  })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name = "nat-gw-${var.environment}"
  })

  depends_on = [aws_eip.nat, aws_subnet.public]
}