# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones to use for subnets"
  type        = list(string)
}

# Subnets
variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

# Internet Gateway
variable "igw_name" {
  description = "Name for the internet gateway"
  type        = string
}

# Elastic IP for NAT
variable "nat_eip_name" {
  description = "Name for the Elastic IP to be used by NAT Gateway"
  type        = string
}

# NAT Gateway
variable "nat_gateway_name" {
  description = "Name of the NAT Gateway"
  type        = string
}

# Route tables
variable "public_route_table_name" {
  description = "Name of the public route table"
  type        = string
}

variable "private_route_table_name" {
  description = "Name of the private route table"
  type        = string
}

# EKS
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "eks_version" {
  description = "Version of the EKS cluster"
  type        = string
}

# IAM roles
variable "eks_iam_role_name" {
  description = "IAM role name for the EKS cluster"
  type        = string
}

variable "node_iam_role_name" {
  description = "IAM role name for the EKS node group"
  type        = string
}

# Node group
variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "instance_types" {
  description = "List of EC2 instance types for the EKS node group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
}

# Load Balancer
variable "lbc_iam_role" {
  description = "IAM role ARN for the Load Balancer Controller"
  type        = string
}

variable "lbc_name" {
  description = "Name of the Load Balancer Controller"
  type        = string
}

variable "lbc_namespace" {
  description = "The namespace of the load balancer controller"
  type        = string
}