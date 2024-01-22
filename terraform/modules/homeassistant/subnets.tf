data "aws_availability_zones" "azs" {}

resource "aws_subnet" "public" {
  count             = local.az_count
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)

  tags = {
    Name        = "subnet-public-${count.index}"
    Environment = var.environment
  }
}
