resource "aws_security_group" "imap_instance" {
  name_prefix = "${var.cluster_name}-instance"
  vpc_id      = "${aws_vpc.vpc.id}"
  description = "Security group for IMAP instances"

  tags = {
    Name = "${var.cluster_name}-instance"
  }
}

resource "aws_security_group_rule" "imap_ingress_imap" {
  security_group_id = "${aws_security_group.imap_instance.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 143
  to_port           = 143
  protocol          = "tcp"
}

resource "aws_security_group_rule" "imap_ingress_lmtp" {
  security_group_id = "${aws_security_group.imap_instance.id}"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 24
  to_port           = 24
  protocol          = "tcp"
}

resource "aws_security_group_rule" "imap_egress_http" {
  security_group_id = "${aws_security_group.imap_instance.id}"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}
