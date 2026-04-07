variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "enable_dns_support" {
  type        = bool
  default     = true
  description = "Enable DNS support in VPC"
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "Enable DNS hostnames in VPC"
}

variable "environment" {
  type        = string
  description = "Environment name (dev/prod)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags to apply to resources"
}