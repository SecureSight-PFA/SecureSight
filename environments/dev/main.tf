module "vpc" {
  source   = "../../terraform/modules/vpc"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "subnets" {
  source = "../../terraform/modules/subnets"

  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

}

module "igw" {
  source   = "../../terraform/modules/igw"

  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name

}

module "eip" {
  source = "../../terraform/modules/eip"

  nat_eip_name = var.nat_eip_name
}

module "nat" {
  source = "../../terraform/modules/nat"

  nat_gateway_name  = var.nat_gateway_name
  public_subnet_id  = module.subnets.public_subnet_ids[0]
  eip_allocation_id = module.eip.eip_allocation_id
  gateway_id        = module.igw.gateway_id
}

module "routes" {
  source = "../../terraform/modules/routes"

  vpc_id                   = module.vpc.vpc_id
  private_route_table_name = var.private_route_table_name
  public_route_table_name  = var.public_route_table_name
  gateway_id               = module.igw.gateway_id
  nat_gateway_id           = module.nat.nat_gateway_id 
  public_subnet_ids        = module.subnets.public_subnet_ids
  private_subnet_ids       = module.subnets.private_subnet_ids
}

module "iam" {
  source = "../../terraform/modules/iam"

  eks_iam_role_name                 = var.eks_iam_role_name
  node_iam_role_name                = var.node_iam_role_name
  kms_id                            = module.eks.kms_id
  eks_cluster_name                  = module.eks.eks_cluster_name
}

module "eks" {
  source = "../../terraform/modules/eks"

  vpc_id             = module.vpc.vpc_id
  eks_cluster_name   = var.eks_cluster_name
  eks_version        = var.eks_version
  private_subnet_ids = module.subnets.private_subnet_ids
  eks_role_arn       = module.iam.eks_iam_role_arn
}

module "nodes" {
  source = "../../terraform/modules/nodes"

  eks_cluster_name   = module.eks.eks_cluster_name
  node_group_name    = var.node_group_name
  private_subnet_ids = module.subnets.private_subnet_ids
  node_role_arn      = module.iam.node_iam_role_arn
  instance_types     = var.instance_types
  desired_size       = var.desired_size
  min_size           = var.min_size
  max_size           = var.max_size


  depends_on = [
    module.iam, 
    module.eks  
  ]             
}

module "lb" {
  source = "../../terraform/modules/lb" 

 eks_cluster_name         = module.eks.eks_cluster_name
 vpc_id                   = module.vpc.vpc_id
 lbc_iam_role             = var.lbc_iam_role
 lbc_name                 = var.lbc_name
 lbc_namespace            = var.lbc_namespace
}

module "ebs" {
  source = "../../terraform/modules/ebs" 
  eks_cluster_name            = module.eks.eks_cluster_name
}

module "csi_driver" {
  source                = "../../terraform/modules/csi-driver"

  eks_cluster_name      = var.eks_cluster_name
  csi_chart_name        = var.csi_chart_name
  vpc_id                = module.vpc.vpc_cidr
  aws_csi_chart_name    = var.aws_csi_chart_name
}

module "carts_db_secret" {
  source                   = "../../terraform/modules/secrets-manager"
  secret_name              = var.carts_db_secret_name
}

module "catalogue_db_secret" {
  source                   = "../../terraform/modules/secrets-manager"
  secret_name              = var.catalogue_db_secret_name
}

module "user_db_secret" {
  source                   = "../../terraform/modules/secrets-manager"
  secret_name              = var.user_db_secret_name
}

module "session_db_secret" {
  source                   = "../../terraform/modules/secrets-manager"
  secret_name              = var.session_db_secret_name
}

module "orders_db_secret" {
  source                   = "../../terraform/modules/secrets-manager"
  secret_name              = var.orders_db_secret_name
}