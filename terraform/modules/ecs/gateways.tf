resource "aws_internet_gateway" "ecs" {
  vpc_id = "${aws_vpc.ecs.id}"

  tags = {
    Name        = "ecs-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_nat_gateway" "ecs" {
  count         = "${local.az_count}"
  allocation_id = "${element(aws_eip.egress.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags = {
    Name        = "ecs-${var.environment}"
    Environment = "${var.environment}"
  }
}
