variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "availability_zones" {
  description = "availability zones"
  type    = list(string)
}

variable "public_subnet_cidrs" {
  description = "cidr of the public subnets"
  type    = list(string)
}

variable "private_subnet_cidrs" {
  description = "cidr of the private subnets"
  type    = list(string)
}

