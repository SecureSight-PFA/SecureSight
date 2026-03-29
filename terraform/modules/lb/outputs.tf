output "lbc_iam_role_arn" {
  description = "LBC iam role arn"
  value       = aws_iam_role.aws_lbc.arn
}

output "lbc_iam_role_name" {
  description = "LBC iam role name"
  value       = aws_iam_role.aws_lbc.name
}

output "lbc_iam_policy_arn" {
  description = "LBC iam policy arn"
  value       = aws_iam_policy.aws_lbc.arn
}

