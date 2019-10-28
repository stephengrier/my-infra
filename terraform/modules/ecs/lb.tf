resource "aws_lb" "nlb" {
  name               = "${var.cluster_name}-nlb"
  load_balancer_type = "network"
  internal           = false
  subnets            = "${aws_subnet.public.*.id}"

  tags = {
    Name        = "${var.cluster_name}-nlb"
    Environment = "${var.environment}"
  }
}
