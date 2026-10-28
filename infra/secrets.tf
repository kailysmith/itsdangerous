resource "random_password" "signing_key" {
  length  = 64
  special = true
}

resource "aws_secretsmanager_secret" "signing_key" {
  name                    = "app/${var.project_name}/signing-secret-key"
  description             = "itsdangerous HMAC signing secret key"
  kms_key_id              = aws_kms_key.secrets.arn
  recovery_window_in_days = 30

  tags = {
    Name = "${local.name_prefix}-signing-key"
  }
}

resource "aws_secretsmanager_secret_version" "signing_key" {
  secret_id     = aws_secretsmanager_secret.signing_key.id
  secret_string = random_password.signing_key.result

  lifecycle {
    ignore_changes = [secret_string]
  }
}
