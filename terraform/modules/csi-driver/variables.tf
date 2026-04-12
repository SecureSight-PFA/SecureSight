variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "csi_chart_name" {
  description = "Name of the Helm chart for the CSI driver"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where EKS cluster and resources are deployed"
  type        = string
}

variable "aws_csi_chart_name" {
  description = "Name of the Helm chart for the AWS CSI driver provider"
  type        = string
}

