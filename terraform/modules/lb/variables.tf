variable "eks_cluster_name" {
  description = "The cluster name"
  type        = string
}

variable "vpc_id" {
  description = "The id of the vpc"
  type        = string
}

variable "lbc_iam_role" {
  description = "The iam role of the load balancer"
  type        = string
}

variable "lbc_name" {
  description = "The name of the load balancer controller"
  type        = string
}

variable "lbc_namespace" {
  description = "The namespace of the load balancer controller"
  type        = string
}