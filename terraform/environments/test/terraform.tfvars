environment        = "dev"
region             = "us-east-2"
cluster_name       = "securesight-test"
kubernetes_version = "1.3"

vpc_cidr             = "10.2.0.0/16"
availability_zones   = ["us-east-2a", "us-east-2b"]
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]

node_instance_type = "t3.medium"
node_desired       = 1
node_min           = 1
node_max           = 2