# ─── ECS Task Execution Role ───────────────────────────────────────────────────
resource "aws_iam_role" "ecs_execution" {
  name = "${local.name_prefix}-ecs-exec-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Name = "${local.name_prefix}-ecs-exec-role"
  }
}

data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ecs_execution_policy" {
  name        = "${local.name_prefix}-ecs-exec-policy"
  description = "Execution role policy for ECS tasks"
  policy      = data.aws_iam_policy_document.ecs_execution_policy.json
}

data "aws_iam_policy_document" "ecs_execution_policy" {
  statement {
    sid    = "ECRGetAuthToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECRPullImage"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/itsdangerous"]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]
    resources = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/itsdangerous:*"]
  }

  statement {
    sid    = "SecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.db_password.arn,
      aws_secretsmanager_secret.secret_key.arn
    ]
  }

  statement {
    sid    = "KMSDecryptForSecrets"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.cmk.arn]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = aws_iam_policy.ecs_execution_policy.arn
}

# ─── ECS Task Role ─────────────────────────────────────────────────────────────
resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json

  tags = {
    Name = "${local.name_prefix}-ecs-task-role"
  }
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "${local.name_prefix}-ecs-task-policy"
  description = "Task role policy for itsdangerous ECS tasks"
  policy      = data.aws_iam_policy_document.ecs_task_policy.json
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    sid    = "SecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.db_password.arn,
      aws_secretsmanager_secret.secret_key.arn
    ]
  }

  statement {
    sid    = "S3ReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.artifacts.arn}/*"]
  }

  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.artifacts.arn]
  }

  statement {
    sid    = "KMSCrypto"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.cmk.arn]
  }

  statement {
    sid    = "XRayTracing"
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

# ─── Auto Scaling Role ─────────────────────────────────────────────────────────
resource "aws_iam_role" "ecs_autoscaling" {
  name = "${local.name_prefix}-ecs-asg-role"

  assume_role_policy = data.aws_iam_policy_document.autoscaling_assume_role.json

  tags = {
    Name = "${local.name_prefix}-ecs-asg-role"
  }
}

data "aws_iam_policy_document" "autoscaling_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_autoscaling_policy" {
  role       = aws_iam_role.ecs_autoscaling.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}
