output "eks_iam_role_arn" {
  description = "ARN of the IAM role associated with the EKS control plane"
  value = aws_iam_role.eks.arn
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role associated with the EKS worker nodes"
  value = aws_iam_role.nodes.arn
}

output "db_role_name" {
  description = "IAM role name used by the database service account"
  value       = aws_iam_role.db_role.name
}

output "db_role_arn" {
  description = "IAM role ARN used by the database service account"
  value       = aws_iam_role.db_role.arn
}