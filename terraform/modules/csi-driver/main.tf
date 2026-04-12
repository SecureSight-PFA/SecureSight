# Documentation: https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release

# CSI driver
resource "helm_release" "csi_driver" {
  name = var.csi_chart_name

  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"
  version    = "1.5.3"            

  set = [
  { 
    name  = "clusterName"
    value = var.eks_cluster_name
  },

  {
    name  = "vpcId"
    value = var.vpc_id
  }
]
}

# CSI driver provider: AWS
resource "helm_release" "aws_csi_driver" {
  name = var.aws_csi_chart_name

  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  version    = "2.0.0"            

  set = [
  { 
    name  = "clusterName"
    value = var.eks_cluster_name
  },

  {
    name  = "vpcId"
    value = var.vpc_id
  }
]
}
