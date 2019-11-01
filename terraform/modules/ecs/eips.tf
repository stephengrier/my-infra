resource "aws_eip" "egress" {
  count = "${local.az_count}"
  vpc   = true
}
