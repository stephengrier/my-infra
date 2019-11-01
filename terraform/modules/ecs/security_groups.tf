resource "aws_security_group" "common" {
  name        = "ecs-common"
  description = "Common security group for ECS instances"
  vpc_id      = "${aws_vpc.ecs.id}"
}

resource "aws_security_group_rule" "common_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.common.id}"
}
