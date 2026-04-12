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
  depends_on = [module.eks]
}

provider "helm" {
  kubernetes = {          
    host                   = data.aws_eks_cluster.eks.endpoint  
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data) 

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"  
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]  
    }
  }
}
