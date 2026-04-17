# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster 

# IAM role for EKS 
resource "aws_iam_role" "eks" {
  name = var.eks_iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks.name 
}

#----------------------------------------------------------------------------------------------------------
# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group

# IAM role for the Node group
resource "aws_iam_role" "nodes" {
  name = var.node_iam_role_name

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"  # Allows nodes to pull form ECR
  role       = aws_iam_role.nodes.name
}

#------------------------------------------ Autoscaler ----------------------------------------------------------------
# IAM Policy for the Autoscaler 
resource "aws_iam_policy" "cluster_autoscaler" {
  name = "ClusterAutoscalerPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role: simplified trust policy, no OIDC needed
resource "aws_iam_role" "cluster_autoscaler" {
  name = "ClusterAutoscalerRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
      }
    ]
  })
}

# Policy attachment 
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

# Pod Identity Agent addon
# done in lb/main.tf

# Associate IAM role with K8s ServiceAccount
resource "aws_eks_pod_identity_association" "cluster_autoscaler" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "cluster-autoscaler"
  role_arn        = aws_iam_role.cluster_autoscaler.arn
}

# -------------------- IAM for CSI driver to access secrets ---------------------------

data "aws_iam_policy_document" "db_assume" {
  statement {
    actions = ["sts:AssumeRole", "sts:TagSession"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "db_role" {
  name               = "${var.eks_cluster_name}-db-role"
  assume_role_policy = data.aws_iam_policy_document.db_assume.json
}

resource "aws_iam_policy" "db_secrets" {
  name = "${var.eks_cluster_name}-db-secrets"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = "*"   
    }]
  })
}

resource "aws_iam_role_policy_attachment" "db_secrets" {
  role       = aws_iam_role.db_role.name
  policy_arn = aws_iam_policy.db_secrets.arn
}

resource "aws_eks_pod_identity_association" "db" {
  cluster_name    = var.eks_cluster_name
  namespace       = "sock-shop"
  service_account = "db-sa"           
  role_arn        = aws_iam_role.db_role.arn
}

# ------------------------------------- RBAC for SSO groups -------------------------------------------
/* Access entries for SSO groups to access the cluster, mapped to Kubernetes groups for RBAC. This is the modern way that replaces the old aws-auth configmap. It is more secure and easier to manage, but requires AWS SSO and IAM Identity Center setup.
resource "aws_eks_access_entry" "dev_team" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::014498640042:role/AWSReservedSSO_DevTeam_xxx"

  kubernetes_groups = ["dev"]
}

resource "aws_eks_access_entry" "sre_team" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::014498640042:role/AWSReservedSSO_SRETeam_xxx"

  kubernetes_groups = ["sre"]
}

+ We create RBAC Roles and RoleBindings!

*/

# Option 1:
# SSO IAM Role
#   ↓
# EKS Access Entry (maps to group)
#   ↓
# Kubernetes RBAC (RoleBinding) (fine-grained control))
#   ↓
# Permissions enforced
# -------------------------------------------------

# Option 2:
# SSO IAM Role
#   ↓
# EKS Access Entry
#    ↓
# AWS Access Policy (View/Edit/Admin)
#    ↓
# Direct Kubernetes API permissions (AWS predefined access levels)

/* DevOps team READ-ONLY:
resource "aws_eks_access_entry" "devops" {
  cluster_name  = var.cluster_name
  principal_arn = "arn:aws:iam::014498640042:role/AWSReservedSSO_DevOpsTeam_xxx"
}

resource "aws_eks_access_policy_association" "devops_view" {
  cluster_name  = var.cluster_name
  principal_arn = aws_eks_access_entry.devops.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}

The DevOps team now gets (without creating rolebindings):

- kubectl get pods
- kubectl get services
- kubectl get namespaces
*/