variable "subnet_id" {}
variable "security_group" {}
variable "execution_role" {}
variable "log_group_name" {}
variable "region" {}
variable "target_group_arn" {}
variable "listener_dependency" {}



resource "aws_ecs_cluster" "cluster" {
  name = "mi-cluster-ecs"
}

resource "aws_ecs_task_definition" "task" {
  family                   = "mi-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.execution_role

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "920372986337.dkr.ecr.us-east-1.amazonaws.com/mi-ssr:latest"
      essential = true

      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = var.log_group_name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "service" {
  name            = "mi-servicio"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [var.security_group]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "app"
    container_port   = 3000
  }

  depends_on = [var.listener_dependency]
}

