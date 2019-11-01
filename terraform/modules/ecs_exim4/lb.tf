resource "aws_lb_target_group" "target" {
  name        = "exim4"
  port        = 8025
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = 8025
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }
}

resource "aws_lb_listener" "smtp" {
  load_balancer_arn = "${var.nlb_arn}"
  protocol          = "TCP"
  port              = 25

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target.arn}"
  }
}
