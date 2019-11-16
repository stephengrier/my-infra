resource "aws_eip" "egress" {
  count             = "${local.az_count}"
  vpc               = true
  network_interface = "${element(aws_network_interface.nat_eni.*.id, count.index)}"

  tags = {
    Name = "egress-eip-${count.index}"
  }
}
