resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "secret_key" {
  length           = 64
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "itsdangerous/db_password"
  description             = "RDS PostgreSQL master password for itsdangerous"
  kms_key_id              = aws_kms_key.cmk.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret" "secret_key" {
  name                    = "itsdangerous/secret_key"
  description             = "Application secret key for itsdangerous"
  kms_key_id              = aws_kms_key.cmk.arn
  recovery_window_in_days = 7

  tags = {
    Name = "${local.name_prefix}-secret-key"
  }
}

resource "aws_secretsmanager_secret_version" "secret_key" {
  secret_id     = aws_secretsmanager_secret.secret_key.id
  secret_string = random_password.secret_key.result
}
