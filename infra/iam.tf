# ─── ECS Task Execution Role ───────────────────────────────────────────────
data "aws_iam_policy_document" "ecs_task_execution_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${local.name_prefix}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume.json

  tags = {
    Name = "${local.name_prefix}-exec-role"
  }
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  # ECR auth token — AWS mandates Resource: * for this action
  statement {
    sid    = "ECRGetAuthToken"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  # ECR image pull
  statement {
    sid    = "ECRImagePull"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [aws_ecr_repository.app.arn]
  }

  # CloudWatch Logs write
  statement {
    sid    = "CloudWatchLogsWrite"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.ecs.arn}:*"]
  }

  # Secrets Manager read (for secret injection at task start)
  statement {
    sid    = "SecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [aws_secretsmanager_secret.signing_key.arn]
  }

  # KMS decrypt for Secrets Manager
  statement {
    sid    = "KMSDecryptForSecrets"
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.secrets.arn]
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
  name   = "${local.name_prefix}-exec-policy"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json

  tags = {
    Name = "${local.name_prefix}-exec-policy"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}

# ─── ECS Task Role ─────────────────────────────────────────────────────────
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  name               = "${local.name_prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json

  tags = {
    Name = "${local.name_prefix}-task-role"
  }
}

data "aws_iam_policy_document" "ecs_task_policy" {
  # Secrets Manager runtime read
  statement {
    sid    = "SecretsManagerRuntimeRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [aws_secretsmanager_secret.signing_key.arn]
  }

  # KMS decrypt for signing secret
  statement {
    sid    = "KMSDecryptForSigningSecret"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.secrets.arn]
  }

  # X-Ray tracing
  statement {
    sid    = "XRayTracing"
    effect = "Allow"
    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets"
    ]
    resources = ["arn:aws:xray:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }

  # CloudWatch custom metrics
  statement {
    sid    = "CloudWatchPutMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:PutMetricData"
    ]
    resources = ["arn:aws:cloudwatch:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.name_prefix}-task-policy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json

  tags = {
    Name = "${local.name_prefix}-task-policy"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}
