variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "alb_controller_role_arn" {
  description = "IAM role ARN for ALB controller (from iam/post-eks)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}