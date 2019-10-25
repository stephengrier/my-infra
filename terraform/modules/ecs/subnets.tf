data "aws_availability_zones" "azs" {}

resource "aws_subnet" "public" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.ecs.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.ecs.cidr_block, 8, count.index)}"

  tags = {
    Name        = "public"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "private" {
  count             = "${local.az_count}"
  vpc_id            = "${aws_vpc.ecs.id}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  cidr_block        = "${cidrsubnet(aws_vpc.ecs.cidr_block, 8, 10 + count.index)}"

  tags = {
    Name        = "private"
    Environment = "${var.environment}"
  }
}
