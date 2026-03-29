variable "eks_iam_role_name" {
  description = "The name of the eks iam"
  type        = string
}

variable kms_id {
  type        = string
  description = "The KMS key ID for EKS secrets encryption"
}

variable "node_iam_role_name" {
  description = "iam role of the nodes"
  type        = string
}
