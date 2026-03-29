module "vpc" {
  source   = "../../modules/vpc"

  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "subnets" {
  source = "../../modules/subnets"

  vpc_id               = module.vpc.vpc_id
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

}

module "igw" {
  source   = "../../modules/igw"

  vpc_id   = module.vpc.vpc_id
  igw_name = var.igw_name

}

module "eip" {
  source = "../../modules/eip"

  nat_eip_name = var.nat_eip_name
}

module "nat" {
  source = "../../modules/nat"

  nat_gateway_name  = var.nat_gateway_name
  public_subnet_id  = module.subnets.public_subnet_ids[0]
  eip_allocation_id = module.eip.eip_allocation_id
  gateway_id        = module.igw.gateway_id
}

module "routes" {
  source = "../../modules/routes"

  vpc_id                   = module.vpc.vpc_id
  private_route_table_name = var.private_route_table_name
  public_route_table_name  = var.public_route_table_name
  gateway_id               = module.igw.gateway_id
  nat_gateway_id           = module.nat.nat_gateway_id 
  public_subnet_ids        = module.subnets.public_subnet_ids
  private_subnet_ids       = module.subnets.private_subnet_ids
}

module "iam" {
  source = "../../modules/iam"

  eks_iam_role_name                 = var.eks_iam_role_name
  node_iam_role_name                = var.node_iam_role_name
  kms_id                            = module.eks.kms_id
}

module "eks" {
  source = "../../modules/eks"

  vpc_id             = module.vpc.vpc_id
  eks_cluster_name   = var.eks_cluster_name
  eks_version        = var.eks_version
  private_subnet_ids = module.subnets.private_subnet_ids
  eks_role_arn       = module.iam.eks_iam_role_arn
}

module "nodes" {
  source = "../../modules/nodes"

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
  source = "../../modules/lb" 

 eks_cluster_name         = module.eks.eks_cluster_name
 vpc_id                   = module.vpc.vpc_id
 lbc_iam_role             = var.lbc_iam_role
 lbc_name                 = var.lbc_name
 lbc_namespace            = var.lbc_namespace
}