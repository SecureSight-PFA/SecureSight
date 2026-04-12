# Pod Identity (newer, simpler). No OIDC provider needed
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = var.eks_cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.29.1-eksbuild.1"
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"       
    ]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${var.eks_cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"  # pre-created by AWS: https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEBSCSIDriverPolicy.html
}

resource "aws_eks_pod_identity_association" "ebs_csi" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kube-system"
  service_account = "ebs-csi-controller-sa"
  role_arn        = aws_iam_role.ebs_csi_role.arn
}