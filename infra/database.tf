resource "aws_db_subnet_group" "main" {
  name        = "${local.name_prefix}-db-subnet"
  description = "Subnet group for itsdangerous RDS"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name = "${local.name_prefix}-db-subnet"
  }
}

resource "aws_db_parameter_group" "postgres16" {
  name        = "${local.name_prefix}-pg16"
  family      = "postgres16"
  description = "Custom parameter group for PostgreSQL 16"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = {
    Name = "${local.name_prefix}-pg16"
  }
}

resource "aws_db_instance" "main" {
  identifier              = "${local.name_prefix}-db"
  engine                  = "postgres"
  engine_version          = "16"
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  max_allocated_storage   = var.db_max_allocated_storage
  storage_type            = "gp3"
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.cmk.arn
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.db_password.result
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.rds.id]
  parameter_group_name    = aws_db_parameter_group.postgres16.name
  multi_az                = true
  publicly_accessible     = false
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"
  deletion_protection     = true
  skip_final_snapshot     = false
  final_snapshot_identifier = "${local.name_prefix}-db-final"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  performance_insights_enabled    = true
  performance_insights_kms_key_id = aws_kms_key.cmk.arn

  tags = {
    Name = "${local.name_prefix}-db"
  }
}
