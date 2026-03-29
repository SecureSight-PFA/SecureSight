variable "vpc_id" {
  description = "The ID of the VPC to associate with the Internet Gateway"
  type        = string
}

variable "igw_name" {
  description = "The name tag for the Internet Gateway"
  type        = string
}
