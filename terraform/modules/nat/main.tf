# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway

# NAT gateway for the public subnet of zone 1
resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_allocation_id
  subnet_id     = var.public_subnet_id    

  tags = {
    Name = var.nat_gateway_name
  }

  depends_on = [var.gateway_id] 
}
