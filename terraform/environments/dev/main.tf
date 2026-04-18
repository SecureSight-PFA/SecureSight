module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "subnets" {
  source = "../../modules/subnets"

  vpc_id               = module.vpc.vpc_id
  internet_gateway_id  = module.vpc.internet_gateway_id
  environment          = var.environment
  cluster_name         = var.cluster_name
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

}

module "routes" {
  source = "../../modules/routes"

  vpc_id              = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids
  nat_gateway_ids     = module.subnets.nat_gateway_ids
  environment         = var.environment
}

module "nsg" {
  source = "../../modules/nsg"

  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "iam_pre_eks" {
  source = "../../modules/iam/pre-eks"

  environment = var.environment
}

module "eks" {
  source               = "../../modules/eks"
  cluster_name         = var.cluster_name
  environment          = var.environment
  kubernetes_version   = var.kubernetes_version
  eks_cluster_role_arn = module.iam_pre_eks.eks_cluster_role_arn
  eks_nodes_role_arn   = module.iam_pre_eks.eks_nodes_role_arn
  eks_cluster_sg_id    = module.nsg.eks_cluster_sg_id
  public_subnet_ids    = module.subnets.public_subnet_ids
  private_subnet_ids   = module.subnets.private_subnet_ids
  node_instance_type   = var.node_instance_type
  node_desired         = var.node_desired
  node_min             = var.node_min
  node_max             = var.node_max
}

module "iam_post_eks" {
  source            = "../../modules/iam/post-eks"
  environment       = var.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url
}

module "lb" {
  source                  = "../../modules/lb"
  cluster_name            = var.cluster_name
  environment             = var.environment
  alb_controller_role_arn = module.iam_post_eks.alb_controller_role_arn
  vpc_id                  = module.vpc.vpc_id
  region                  = var.region
}