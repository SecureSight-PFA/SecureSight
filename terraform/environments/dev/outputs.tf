output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "eks_nodes_role_arn" {
  value = module.iam_pre_eks.eks_nodes_role_arn
}

output "alb_controller_role_arn" {
  value = module.iam_post_eks.alb_controller_role_arn
}