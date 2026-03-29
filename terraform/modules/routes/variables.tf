variable "vpc_id" {
  description = "The ID of the VPC to associate with the Internet Gateway"
  type        = string
}

variable "gateway_id" {
  description = "The igw id"
  type        = string
}

variable "nat_gateway_id" {
  description = "The nat id"
  type        = string
}

variable "private_route_table_name" {
  description = "The name of the private route table"
  type        = string
}

variable "public_route_table_name" {
  description = "The name of the public route table"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of IDs for the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of IDs for the private subnets"
  type        = list(string)
}