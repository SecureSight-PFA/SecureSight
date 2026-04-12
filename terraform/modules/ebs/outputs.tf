output "ebs_csi_role_name" {
  description = "IAM role name used by EBS CSI driver"
  value       = aws_iam_role.ebs_csi_role.name
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by EBS CSI driver"
  value       = aws_iam_role.ebs_csi_role.arn
}