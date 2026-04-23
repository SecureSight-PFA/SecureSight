# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group

# Node group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name         = var.eks_cluster_name
  node_group_name      = var.node_group_name
  node_role_arn        = var.node_role_arn  

  subnet_ids     = var.private_subnet_ids     
  instance_types = var.instance_types

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

# In case we'll add cluster autoscaler: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
# Terraform tracks resource attributes and will attempt to modify them if they differ from the configuration.
# However, in this case, the desired_size may be changed outside of Terraform by the Cluster Autoscaler.
# To prevent Terraform from constantly trying to revert these external changes,
# we use ignore_changes to let the autoscaler manage scaling without interference.

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  } 

# Nesessary for the cluster autoscaler
  tags = {
    "k8s.io/cluster-autoscaler/enabled"                 = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
  }

  labels = {
    role = "microservices-nodes"   
  }
}

resource "aws_eks_node_group" "monitoring_node_group" {
  cluster_name    = var.eks_cluster_name
  node_group_name = "monitoring-node-group"
  node_role_arn   = var.node_role_arn

  subnet_ids     = var.private_subnet_ids
  instance_types = var.instance_types

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"                 = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
  }

  labels = {
  role = "monitoring"
  }
}


resource "aws_eks_node_group" "monitoring_nodes" {
  cluster_name    = var.eks_cluster_name
  node_group_name = "monitoring-nodes"
  node_role_arn   = var.node_role_arn

  subnet_ids     = var.private_subnet_ids
  instance_types = var.instance_types

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }

  tags = {
    "k8s.io/cluster-autoscaler/enabled"                 = "true"
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
  }

  labels = {
  role = "monitoring-nodes"
  }

  taint {
    key    = "role"
    value  = "monitoring-nodes"
    effect = "NO_SCHEDULE"
  }
}

