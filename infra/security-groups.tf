resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTPS from internet"
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow HTTP from internet (redirect to HTTPS)"
}

resource "aws_security_group_rule" "alb_egress_fargate" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.fargate.id
  description              = "Allow egress to Fargate tasks on port 8080"
}

resource "aws_security_group" "fargate" {
  name        = "${local.name_prefix}-fargate-sg"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-fargate-sg"
  }
}

resource "aws_security_group_rule" "fargate_ingress_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.fargate.id
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  description              = "Allow ingress from ALB on port 8080"
}

resource "aws_security_group_rule" "fargate_egress_rds" {
  type                     = "egress"
  security_group_id        = aws_security_group.fargate.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  description              = "Allow egress to RDS on port 5432"
}

resource "aws_security_group_rule" "fargate_egress_https" {
  type              = "egress"
  security_group_id = aws_security_group.fargate.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow egress to AWS APIs and ECR over HTTPS"
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name_prefix}-rds-sg"
  }
}

resource "aws_security_group_rule" "rds_ingress_fargate" {
  type                     = "ingress"
  security_group_id        = aws_security_group.rds.id
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.fargate.id
  description              = "Allow ingress from Fargate tasks on port 5432"
}
