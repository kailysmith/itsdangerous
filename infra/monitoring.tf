# ─── CloudWatch Log Group ──────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = aws_kms_key.cloudwatch.arn

  tags = {
    Name = "${local.name_prefix}-ecs-logs"
  }
}

# ─── ECS Alarms ───────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_warning" {
  alarm_name          = "${local.name_prefix}-ecs-cpu-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "ECS CPU utilisation > 70%"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

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
  alarm_description   = "ECS CPU utilisation > 90%"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

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
  alarm_description   = "ECS memory utilisation > 70%"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

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
  alarm_description   = "ECS memory utilisation > 90%"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${local.name_prefix}-ecs-mem-crit"
  }
}

resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {
  alarm_name          = "${local.name_prefix}-ecs-tasks-crit"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "ECS running task count < 1"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.app.name
  }

  tags = {
    Name = "${local.name_prefix}-ecs-tasks-crit"
  }
}

# ─── ALB Alarms ───────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "alb_5xx_warning" {
  alarm_name          = "${local.name_prefix}-alb-5xx-warn"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB 5xx errors > 10 per minute"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-5xx-warn"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_critical" {
  alarm_name          = "${local.name_prefix}-alb-5xx-crit"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 50
  alarm_description   = "ALB 5xx errors > 50 per minute"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-5xx-crit"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time_p99" {
  alarm_name          = "${local.name_prefix}-alb-lat-p99"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  extended_statistic  = "p99"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  threshold           = 0.2
  alarm_description   = "ALB p99 response time > 200ms (SLO breach)"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-lat-p99"
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
  alarm_description   = "ALB unhealthy host count > 0"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-alb-unhealthy"
  }
}

# ─── WAF Alarms ───────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "waf_blocked_requests" {
  alarm_name          = "${local.name_prefix}-waf-blocked"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BlockedRequests"
  namespace           = "AWS/WAFV2"
  period              = 300
  statistic           = "Sum"
  threshold           = 500
  alarm_description   = "WAF blocked requests spike > 500 per 5 min"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    WebACL = aws_wafv2_web_acl.main.name
    Region = data.aws_region.current.name
    Rule   = "ALL"
  }

  tags = {
    Name = "${local.name_prefix}-waf-blocked"
  }
}

# ─── NAT Gateway Alarms ───────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "nat_error_port_allocation" {
  alarm_name          = "${local.name_prefix}-nat-port-err"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ErrorPortAllocation"
  namespace           = "AWS/NATGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "NAT Gateway port allocation errors detected"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    NatGatewayId = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${local.name_prefix}-nat-port-err"
  }
}

resource "aws_cloudwatch_metric_alarm" "nat_packets_drop" {
  alarm_name          = "${local.name_prefix}-nat-pkt-drop"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "PacketsDropCount"
  namespace           = "AWS/NATGateway"
  period              = 60
  statistic           = "Sum"
  threshold           = 100
  alarm_description   = "NAT Gateway packet drop count > 100"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    NatGatewayId = aws_nat_gateway.main[0].id
  }

  tags = {
    Name = "${local.name_prefix}-nat-pkt-drop"
  }
}

# ─── SLO Alarms ───────────────────────────────────────────────────────────
resource "aws_cloudwatch_metric_alarm" "slo_availability" {
  alarm_name          = "${local.name_prefix}-slo-avail"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "SLO breach: signing endpoint availability < 99.9%"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-slo-avail"
  }
}

resource "aws_cloudwatch_metric_alarm" "slo_latency_p95" {
  alarm_name          = "${local.name_prefix}-slo-lat-p95"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  extended_statistic  = "p95"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  threshold           = 0.2
  alarm_description   = "SLO breach: p95 signing latency > 200ms"
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []
  ok_actions          = var.alarm_sns_topic_arn != "" ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.app.arn_suffix
  }

  tags = {
    Name = "${local.name_prefix}-slo-lat-p95"
  }
}

# ─── CloudWatch Dashboard ─────────────────────────────────────────────────
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
          title  = "ECS CPU & Memory Utilisation"
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.main.name, "ServiceName", aws_ecs_service.app.name]
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
          title  = "ALB Request Count & 5xx Errors"
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", aws_lb.main.arn_suffix],
            ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", aws_lb.main.arn_suffix]
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
          title  = "ALB Target Response Time (p99)"
          period = 60
          stat   = "p99"
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", aws_lb.main.arn_suffix]
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
          title  = "WAF Blocked Requests"
          period = 300
          stat   = "Sum"
          metrics = [
            ["AWS/WAFV2", "BlockedRequests", "WebACL", aws_wafv2_web_acl.main.name, "Region", data.aws_region.current.name, "Rule", "ALL"]
          ]
        }
      }
    ]
  })
}
