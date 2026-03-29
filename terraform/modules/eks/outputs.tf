output "eks_cluster_name" {
  description = "The ID of the created VPC"
  value       = aws_eks_cluster.eks.name
}

output kms_id {
  description = "The ID of the KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks_secrets.key_id
}

output kms_arn {
  description = "The ARN of the KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks_secrets.arn
}


