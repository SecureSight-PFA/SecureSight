# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.private_route_table_name
  }
}

resource "aws_route" "private_default" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.public_route_table_name
  }
}

resource "aws_route" "public_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.gateway_id
}

# Route Table Associations
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_ids)
  subnet_id      = var.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private.id 
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_ids)
  subnet_id      = var.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public.id 
}