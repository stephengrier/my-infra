data "template_file" "task_definition" {
  template = "${file("${path.module}/files/task-definition.json")}"

  vars = {
    account_id = "${data.aws_caller_identity.account.account_id}"
    region     = "${data.aws_region.current.name}"
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = "exim4"
  container_definitions = "${data.template_file.task_definition.rendered}"
  network_mode          = "host"
}

resource "aws_ecs_service" "service" {
  name            = "exim4"
  task_definition = "${aws_ecs_task_definition.task.arn}"
  cluster         = "${var.ecs_cluster_arn}"
  desired_count   = "${var.desired_count}"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 100

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target.id}"
    container_name   = "exim4"
    container_port   = "8025"
  }
}
