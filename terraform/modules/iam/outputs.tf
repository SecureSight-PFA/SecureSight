output "eks_iam_role_arn" {
  description = "ARN of the IAM role associated with the EKS control plane"
  value = aws_iam_role.eks.arn
}

output "node_iam_role_arn" {
  description = "ARN of the IAM role associated with the EKS worker nodes"
  value = aws_iam_role.nodes.arn
}
