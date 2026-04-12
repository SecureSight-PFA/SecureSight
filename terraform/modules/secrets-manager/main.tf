resource "random_password" "password" { 
  length           = 16           
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "password_secret" {
  name = var.secret_name
}

resource "aws_secretsmanager_secret_version" "secret_manager" {
  secret_id                = aws_secretsmanager_secret.password_secret.id
  secret_string            = random_password.password.result
}
