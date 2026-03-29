variable "eks_cluster_name" {
  description = "The name of the node group"
  type        = string
}

variable "node_group_name" {
  description = "The name of the node group"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs for the private subnets"
  type        = list(string)
}

variable "node_role_arn" {
  description = "ARN of the IAM role for EKS cluster"
  type        = string
}

variable "instance_types" {
  description = "List of EC2 instance types for the node group"
  type        = list(string)
}

variable "desired_size" {
  description = "The desired number of worker nodes in the node group"
  type        = number
}
variable "min_size" {
  description = "The minimum number of worker nodes in the node group"
  type        = number
}
variable "max_size" {
  description = "The maximum number of worker nodes in the node group"
  type        = number
}