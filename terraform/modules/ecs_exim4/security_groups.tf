resource "aws_security_group_rule" "common_ingress_lb" {
  type              = "ingress"
  from_port         = 8025
  to_port           = 8025
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${var.ecs_sg_id}"
}
