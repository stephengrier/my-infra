resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.resource_name}-gateway"
    Environment = "${var.environment}"
  }
}
