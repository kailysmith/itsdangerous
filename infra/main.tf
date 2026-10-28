locals {
  name_prefix = substr("${var.project_name}-${var.environment}", 0, 20)
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
