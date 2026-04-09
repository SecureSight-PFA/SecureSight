# Security group for EKS control plane (for the cluster)
resource "aws_security_group" "eks_cluster" {
  name        = "${var.environment}-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-eks-cluster-sg"
  }
}

# Security group for EKS worker nodes (for the nodes)
resource "aws_security_group" "eks_nodes" {
  name        = "${var.environment}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  # Nodes can talk to each other freely
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    description = "Allow node-to-node communication"
  }

  # Control plane can reach nodes (for kubelet, metrics..)
  ingress {
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_cluster.id]
    description     = "Allow control plane to communicate with nodes"
  }

  # Allow ALB to reach pods
  ingress {
    from_port       = 8079
    to_port         = 8079
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow ALB to reach front-end pods"
  }

  # Allow all outbound (nodes need to pull images, call AWS APIs etc)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-eks-nodes-sg"
  }
}

# Security group for ALB 
resource "aws_security_group" "alb" {
  name        = "${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from internet"
  }

  # Allow HTTPS from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from internet"
  }

  # Allow all outbound to nodes
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }
}
