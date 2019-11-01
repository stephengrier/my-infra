resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.ecs.id}"

  tags = {
    Name        = "ecs-public"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_default" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ecs.id}"
}

resource "aws_route_table_association" "public" {
  count          = "${local.az_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table" "private" {
  count  = "${local.az_count}"
  vpc_id = "${aws_vpc.ecs.id}"

  tags = {
    Name        = "ecs-private"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "private_default" {
  count                  = "${local.az_count}"
  destination_cidr_block = "0.0.0.0/0"

  route_table_id = "${element(
    aws_route_table.private.*.id,
    count.index
  )}"

  nat_gateway_id = "${element(
    aws_nat_gateway.ecs.*.id,
    count.index
  )}"
}

resource "aws_route_table_association" "private" {
  count          = "${local.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
