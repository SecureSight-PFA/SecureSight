output "password" {
  value     = random_password.password.result
  sensitive = true
}

output "password_secret" {
  value     = aws_secretsmanager_secret.password_secret.id
}