output "eks_cluster_role_arn" {
  description = "ARN of EKS cluster IAM role — passed to EKS module"
  value       = aws_iam_role.eks_cluster.arn
}

output "eks_node_role_arn" {
  description = "ARN of EKS node group IAM role — passed to EKS module"
  value       = aws_iam_role.eks_nodes.arn
}

output "eks_cluster_role_name" {
  description = "Name of EKS cluster IAM role"
  value       = aws_iam_role.eks_cluster.name
}

output "eks_node_role_name" {
  description = "Name of EKS node IAM role"
  value       = aws_iam_role.eks_nodes.name
}

output "external_secrets_role_arn" {
  description = "ARN of External Secrets IAM role"
  value       = aws_iam_role.external_secrets.arn
}

output "external_secrets_role_name" {
  description = "Name of External Secrets IAM role"
  value       = aws_iam_role.external_secrets.name
}