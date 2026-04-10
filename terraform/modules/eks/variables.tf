variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.29"
}

variable "eks_cluster_role_arn" {
  description = "ARN of the EKS cluster IAM role"
  type        = string
}

variable "eks_nodes_role_arn" {
  description = "ARN of the EKS node group IAM role"
  type        = string
}

variable "eks_cluster_sg_id" {
  description = "Security group ID for EKS cluster"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
}

variable "node_desired" {
  description = "Desired number of nodes"
  type        = number
}

variable "node_min" {
  description = "Minimum number of nodes"
  type        = number
}

variable "node_max" {
  description = "Maximum number of nodes"
  type        = number
}
