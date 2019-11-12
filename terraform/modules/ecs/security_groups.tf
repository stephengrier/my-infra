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

resource "aws_security_group" "nat_instance" {
  name_prefix = "${aws_ecs_cluster.cluster.name}-nat-instance"
  vpc_id      = "${aws_vpc.ecs.id}"
  description = "Security group for NAT instances"

  tags = {
    Name = "${aws_ecs_cluster.cluster.name}-nat-instance"
  }
}

resource "aws_security_group_rule" "nat_egress" {
  security_group_id = "${aws_security_group.nat_instance.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
}

resource "aws_security_group_rule" "nat_ingress" {
  security_group_id = "${aws_security_group.nat_instance.id}"
  type              = "ingress"
  cidr_blocks       = "${aws_subnet.private.*.cidr_block}"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
}
