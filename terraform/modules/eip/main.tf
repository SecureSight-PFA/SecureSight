# Elastic IP address (it is a static public IP that will be associated with the NAT Gateway)

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = var.nat_eip_name
  }
}