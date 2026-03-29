terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

#-------------------------- For Helm --------------------------------------------------------------------------------
# Documentation: https://registry.terraform.io/providers/hashicorp/helm/latest/docs
# & https://developer.hashicorp.com/terraform/tutorials/kubernetes/helm-provider?in=terraform%2Fkubernetes
# Terraform needs explicit authentication to the cluster when using 'helm_release'
# Without this block, Terraform cannot install Helm charts into EKS.

data "aws_eks_cluster" "eks" {
  name = module.eks.eks_cluster_name
}

# This is to authenticate helm to interact with Kubernetes API
provider "helm" {
  kubernetes = {          
    host                   = data.aws_eks_cluster.eks.endpoint  
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) 

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]  
    }
  }
}

# When Terraform runs a helm_release:
# 1. Terraform runs: "aws eks get-token"
# 2. AWS STS (Security Token Service) verifies that terraform is allowed to assume an IAM role, and then gives temporary credentials for that role
# 3. Terraform sends request to Kubernetes API using the temporary token
# 4. Kubernetes:
#      - validates that tokens was issued by AWS STS
#      - uses a special ConfigMap called "aws-auth" in the "kube-system" namespace to map AWS IAM identities (users/roles) to Kubernetes usernames and groups (bridges AWS IAM → Kubernetes RBAC)
# --> Terraform can now do Helm installs/updates charts inside the cluster

# Besides that:
# We are supposed to create an IAM role for Terraform with "eks:GetToken" permissions
# and edit the aws-auth ConfigMap to map the role we created to a Kubernetes username and groups.
# (e.g., username "terraform" and groups "system:masters" for admin permissions)
# Or, for more restricted access, we can create a custom RBAC role with specific permissions.

# In our case:
# - We don’t need to create a separate IAM role or modify aws-auth,
#   because Terraform is using an IAM user (SSO profile) that already has admin permissions.
# - Furthermore, this is the same IAM user that was used to create the EKS cluster.
#   EKS automatically adds the creator identity to the aws-auth ConfigMap in the "kube-system"
#   namespace with groups: "system:masters", giving full admin privileges in Kubernetes.
# - Therefore, Terraform can authenticate and perform Helm installs/updates without any additional setup.