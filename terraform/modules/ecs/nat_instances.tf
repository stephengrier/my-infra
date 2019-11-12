locals {
  spot_instance_types = ["t3.nano", "t3a.nano"]
}

resource "aws_network_interface" "nat_eni" {
  count             = "${local.az_count}"
  security_groups   = ["${aws_security_group.nat_instance.id}"]
  subnet_id         = "${element(aws_subnet.public.*.id, count.index)}"
  source_dest_check = false
  description       = "ENI for NAT instance ${count.index}"

  tags = {
    Name = "nat-instance-eni-${count.index}"
  }
}

resource "aws_eip" "nat" {
  count             = "${local.az_count}"
  network_interface = "${element(aws_network_interface.nat_eni.*.id, count.index)}"

  tags = {
    Name = "nat-instance-eip-${count.index}"
  }
}

data "aws_ami" "amazon_nat" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat-hvm-*"]
  }
}

resource "aws_launch_template" "nat_instance" {
  count       = "${local.az_count}"
  name_prefix = "${aws_ecs_cluster.cluster.name}-nat-instance"
  image_id    = "${data.aws_ami.amazon_nat.id}"

  iam_instance_profile {
    arn = "${aws_iam_instance_profile.nat_instance.arn}"
  }

  network_interfaces {
    delete_on_termination = false
    network_interface_id  = "${element(aws_network_interface.nat_eni.*.id, count.index)}"
  }
}

resource "aws_autoscaling_group" "nat" {
  count              = "${local.az_count}"
  name               = "${aws_ecs_cluster.cluster.name}-nat-asg-${count.index}"
  desired_capacity   = 1
  min_size           = 1
  max_size           = 1
  availability_zones = ["${element(data.aws_availability_zones.azs.names, count.index)}"]

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
    }

    launch_template {
      launch_template_specification {
        launch_template_id = "${element(aws_launch_template.nat_instance.*.id, count.index)}"
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = "${local.spot_instance_types}"

        content {
          instance_type = "${override.value}"
        }
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "${aws_ecs_cluster.cluster.name}-nat-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
