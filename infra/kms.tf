resource "aws_kms_key" "cmk" {
  description             = "${local.name_prefix} customer-managed key"
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  policy = data.aws_iam_policy_document.kms_key_policy.json

  tags = {
    Name = "${local.name_prefix}-cmk"
  }
}

resource "aws_kms_alias" "cmk" {
  name          = "alias/itsdangerous-cmk"
  target_key_id = aws_kms_key.cmk.key_id
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "EnableRootAccountFullAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowSecretsManager"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowRDS"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:RetireGrant"
    ]
    resources = ["*"]
  }
}
