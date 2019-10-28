output "nlb_arn" {
  value = "${aws_lb.nlb.arn}"
}

output "common_sg_id" {
  value = "${aws_security_group.common.id}"
}

output "public_subnet_cidrs" {
  value = "${aws_subnet.public.*.cidr_block}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private.*.id}"
}

output "vpc_id" {
  value = "${aws_vpc.ecs.id}"
}

output "ecs_cluster_arn" {
  value = "${aws_ecs_cluster.cluster.arn}"
}

output "nlb_dns_name" {
  value = "${aws_lb.nlb.dns_name}"
}

output "nlb_zone_id" {
  value = "${aws_lb.nlb.zone_id}"
}
