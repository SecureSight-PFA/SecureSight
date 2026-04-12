# Documentation: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon

# Enabling the pod identity addon, this agent (daemonset) will run on every node in the cluster
resource "aws_eks_addon" "pod_identity" {
  cluster_name = var.eks_cluster_name
  addon_name   = "eks-pod-identity-agent"
  addon_version = "v1.3.8-eksbuild.2"
}

# To get the latest addon version run the command:
# aws eks describe-addon-versions --kubernetes-version 1.33 --addon-name eks-pod-identity-agent

#------------------------------------------------------------------------------------------------------------------------------
# Documentation (Pod Identity): https://www.youtube.com/watch?v=aUjJSorBE70
# & https://aws.amazon.com/blogs/containers/amazon-eks-pod-identity-a-new-way-for-applications-on-eks-to-obtain-iam-credentials/


# Now we're going to use Helm to deploy the AWS LBC as a pod.

# But first and in order for the LBC to interact with AWS APIs from within the cluster (to manage the AWS loadbalancer resource), 
# it must first be authorized!

# Previously, this was done using IRSA (IAM Roles for Service Accounts) with OIDC.
# However, AWS has introduced a new EKS add-on in 2023, called Pod Identity, which simplifies this process. 
# We will use Pod Identity to authenticate the AWS LBC pod.

# The steps are as follows:
# Create an IAM policy that grants the necessary permissions.
# Create an IAM role and attach the policy to it.
# Create a Kubernetes service account for the LBC (see the eks/ folder).
# Associate the IAM role with the service account.

#--------------------------------------------------------------------------------------------------------------------------
# Official source: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_pod_identity_association

data "aws_iam_policy_document" "aws_lbc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "aws_lbc" {
  name               = var.lbc_iam_role
  assume_role_policy = data.aws_iam_policy_document.aws_lbc.json
}

# Official source: https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.13.3/docs/install/iam_policy.json
# This is the policy that AWS recommend using, it grants the necessary permissions for the LBC to manage AWS resources such as ALBs, NLBs, Target Groups...
resource "aws_iam_policy" "aws_lbc" {
  name   = "AWSLoadBalancerController"
  policy = file("${path.module}/AWSLoadBalancerController.json")
}

resource "aws_iam_role_policy_attachment" "aws_lbc" {
  policy_arn = aws_iam_policy.aws_lbc.arn
  role       = aws_iam_role.aws_lbc.name
}

# To bind the IAM role to the service account we don't use annotations (as we do with IRSA), instead we use pod identity association resource.
resource "aws_eks_pod_identity_association" "aws_lbc" {
  cluster_name    = var.eks_cluster_name
  namespace       = var.lbc_namespace
  service_account = var.lbc_name 
  role_arn        = aws_iam_role.aws_lbc.arn   
}

#------------------------------------------------------------------------------------------------------
# Official source: https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
# Now let's deploy the AWS LBC using helm

resource "helm_release" "aws_lbc" {
  name = var.lbc_name

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.lbc_namespace
  version    = "1.13.0"            

  set = [
  { 
    name  = "clusterName"
    value = var.eks_cluster_name
  },

  {
    name  = "serviceAccount.name"
    value = var.lbc_name            # The service account will be generated automatically
  },

  {
    name  = "vpcId"
    value = var.vpc_id
  }
]
}

# NOTE: ALB can terminate TLS, but NLB cannot!