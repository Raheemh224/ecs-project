output "ecs_cluster" {
  value = aws_ecs_cluster.ThreatComposer
}

output "task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}
