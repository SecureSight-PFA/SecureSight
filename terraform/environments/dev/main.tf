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