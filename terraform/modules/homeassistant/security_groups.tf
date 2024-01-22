resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_security_group" "ha_instance" {
  name_prefix = "${local.resource_name}-instance-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Security group for Home Assistant instances"

  tags = {
    Name = "${local.resource_name}-instance-sg"
  }
}

resource "aws_security_group_rule" "ingress_http" {
  security_group_id = aws_security_group.ha_instance.id
  type              = "ingress"
  description       = "Allow ingress to tcp/80 from everywhere"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_https" {
  security_group_id = aws_security_group.ha_instance.id
  type              = "ingress"
  description       = "Allow ingress to tcp/443 from everywhere"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}

resource "aws_security_group_rule" "ingress_mqtt" {
  security_group_id = aws_security_group.ha_instance.id
  type              = "ingress"
  description       = "Allow ingress to tcp/8883 from everywhere"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 8883
  to_port           = 8883
  protocol          = "tcp"
}

resource "aws_security_group_rule" "egress_http" {
  security_group_id = aws_security_group.ha_instance.id
  type              = "egress"
  description       = "Allow egress to tcp/80"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
}

resource "aws_security_group_rule" "egress_https" {
  security_group_id = aws_security_group.ha_instance.id
  type              = "egress"
  description       = "Allow egress to tcp/443"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
}
