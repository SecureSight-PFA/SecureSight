variable "nat_gateway_name" {
  description = "The name tag for the NAT Gateway"
  type        = string
}

variable "gateway_id" {
  description = "The id of the NAT Gateway"
  type = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet"
  type = string
}

variable "eip_allocation_id" {
  description = "The ID of the eip"
  type = string
}


