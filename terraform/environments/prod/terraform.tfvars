environment        = "prod"
region             = "us-east-2"
cluster_name       = "securesight-prod"
kubernetes_version = "1.3"

vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]

node_instance_type = "t3.xlarge"
node_desired       = 3
node_min           = 2
node_max           = 6