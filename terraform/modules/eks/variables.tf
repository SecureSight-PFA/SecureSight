variable "vpc_id" {
  type        = string
}

variable "eks_cluster_name" {
  description = "The cluster name"
  type        = string
}
variable "eks_version" {
  description = "The version of the cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs for the private subnets"
  type        = list(string)
}

variable "eks_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  type        = string
}
