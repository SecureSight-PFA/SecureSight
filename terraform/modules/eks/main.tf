# Documentation: https://aws.amazon.com/blogs/containers/using-eks-encryption-provider-support-for-defense-in-depth/
# & https://docs.aws.amazon.com/eks/latest/userguide/enable-kms.html
# Note: Sealed Secrets do not protect against:
#    Malicious cluster admins
#    Misconfigured RBAC
#    etcd snapshots
#    Compromised control plane storage
# What actually secures secrets inside EKS:
#     EKS Secrets encryption with KMS (baseline)
#     RBAC (who can read secrets)


# KMS key
# Symmetric KMS Keys: One single secret key is used for both encryption and decryption
resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

# KMS alias for easier reference
resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.eks_cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

# EKS cluster
resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  version  = var.eks_version
  role_arn = var.eks_role_arn

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true

    subnet_ids = var.private_subnet_ids
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true # Automatically grants cluster-admin access to the creator
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets.arn
    }
    resources = ["secrets"]
  }
}
