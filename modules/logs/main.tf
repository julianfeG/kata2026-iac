resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/mi-servicio"
  retention_in_days = 7
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.ecs_logs.name
}
