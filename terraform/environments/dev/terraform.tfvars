environment = "dev"
region      = "us-east-2"
cluster_name       = "securesight-dev"
kubernetes_version = "1.29"

vpc_cidr = "10.0.0.0/16"
availability_zones   = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
