# ─── SNS Topic for Alerts ──────────────────────────────────────────────────────
resource "aws_sns_topic" "alerts" {
  name              = "${local.name_prefix}-alerts"
  kms_master_key_id = aws_kms_key.cmk.arn

  tags = {
    Name = "${local.name_prefix}-alerts"
  }
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ─── Additional CloudWatch Log Groups ─────────────────────────────────────────
resource "aws_cloudwatch_log_group" "rds" {
  name              = "/rds/itsdangerous"
  retention_in_days = 30
  kms_key_id        = aws_kms_key.cmk.arn

  tags = {
    Name = "${local.name_prefix}-rds-logs"
  }
}

# ─── ECS Alarms ───────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_warning" {
  alarm_name          = "${local.name_prefix}-ecs-cpu-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "ECS CPU utilization above 70%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${local.name_prefix}-ecs-cpu-warning"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_cpu_critical" {
  alarm_name          = "${local.name_prefix}-ecs-cpu-critical"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "ECS CPU utilization above 90%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${local.name_prefix}-ecs-cpu-critical"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_warning" {
  alarm_name          = "${local.name_prefix}-ecs-mem-warn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "ECS memory utilization above 70%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${local.name_prefix}-ecs-mem-warn"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_critical" {
  alarm_name          = "${local.name_prefix}-ecs-mem-crit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "ECS memory utilization above 90%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${local.name_prefix}-ecs-mem-crit"
  }
}

# ─── RDS Alarms ───────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "rds_cpu_warning" {
  alarm_name          = "${local.name_prefix}-rds-cpu-warn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "RDS CPU utilization above 70%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = {
    Name = "${local.name_prefix}-rds-cpu-warn"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_critical" {
  alarm_name          = "${local.name_prefix}-rds-cpu-crit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 90
  alarm_description   = "RDS CPU utilization above 90%"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = {
    Name = "${local.name_prefix}-rds-cpu-crit"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_warning" {
  alarm_name          = "${local.name_prefix}-rds-storage-warn"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120
  alarm_description   = "RDS free storage below 5 GB"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = {
    Name = "${local.name_prefix}-rds-storage-warn"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_free_storage_critical" {
  alarm_name          = "${local.name_prefix}-rds-storage-crit"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648
  alarm_description   = "RDS free storage below 2 GB"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = {
    Name = "${local.name_prefix}-rds-storage-crit"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_freeable_memory" {
  alarm_name          = "${local.name_prefix}-rds-mem-warn"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 134217728
  alarm_description   = "RDS freeable memory below 128 MB"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = {
    Name = "${local.name_prefix}-rds-mem-warn"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_warning" {
  alarm_name          = "${local.name_prefix}-rds-conn-warn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS database connections above 80"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.identifier
  }

  tags = {
    Name = "${local.name_prefix}-rds-conn-warn"
  }
}

# ─── ALB Alarms ───────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "alb_5xx_critical" {
  alarm_name          = "${local.name_prefix}-alb-5xx-crit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB target 5xx errors above 10 per minute"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-5xx-crit"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "${local.name_prefix}-alb-unhealthy"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-unhealthy"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_p99_latency" {
  alarm_name          = "${local.name_prefix}-alb-p99-lat"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  extended_statistic  = "p99"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  threshold           = 0.5
  alarm_description   = "ALB p99 response time above 500ms"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-p99-lat"
  }
}

# ─── WAF Alarms ───────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "${local.name_prefix}-waf-blocked"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 100
  alarm_description   = "WAF blocked requests spike"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = var.region
    Rule   = "ALL"
  }

  tags = {
    Name = "${local.name_prefix}-waf-blocked"
  }
}

# ─── KMS Alarm ────────────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "kms_key_usage" {
  alarm_name          = "${local.name_prefix}-kms-usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "NumberOfRequestsSucceeded"
  namespace           = "AWS/KMS"
  period              = 300
  statistic           = "Sum"
  threshold           = 10000
  alarm_description   = "KMS key usage anomaly"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  treat_missing_data  = "notBreaching"

  dimensions = {
    KeyId = aws_kms_key.cmk.key_id
  }

  tags = {
    Name = "${local.name_prefix}-kms-usage"
  }
}

# ─── CloudWatch Dashboard ─────────────────────────────────────────────────────
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${local.name_prefix}-overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS CPU Utilization"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "ECS Memory Utilization"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "RDS CPU Utilization"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.main.identifier]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "ALB 5xx Errors"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "WAF Blocked Requests"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", aws_wafv2_web_acl.main.name, "Region", var.region, "Rule", "ALL"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "RDS Free Storage Space"
          view   = "timeSeries"
          region = var.region
          metrics = [
            ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", aws_db_instance.main.identifier]
          ]
        }
      }
    ]
  })
}
