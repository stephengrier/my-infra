resource "aws_ecs_cluster" "cluster" {
  name = "${var.cluster_name}"
}

data "aws_ami" "amazonlinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/files/cloud-init.sh")}"

  vars = {
    cluster = "${aws_ecs_cluster.cluster.name}"
  }
}

resource "aws_launch_template" "cluster" {
  name_prefix            = "${aws_ecs_cluster.cluster.name}-instance"
  image_id               = "${data.aws_ami.amazonlinux.id}"
  user_data              = "${base64encode(data.template_file.user_data.rendered)}"
  vpc_security_group_ids = ["${aws_security_group.common.id}"]

  iam_instance_profile {
    name = "${aws_iam_instance_profile.instance.name}"
  }
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                = "${aws_ecs_cluster.cluster.name}"
  vpc_zone_identifier = "${aws_subnet.private.*.id}"
  max_size            = "${var.number_of_instances}"
  min_size            = "${var.number_of_instances}"
  desired_capacity    = "${var.number_of_instances}"

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = "${aws_launch_template.cluster.id}"
      }

      override {
        instance_type = "t3.nano"
      }

      override {
        instance_type = "t2.nano"
      }

      override {
        instance_type = "t3.micro"
      }

      override {
        instance_type = "t2.micro"
      }
    }

    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_instance_pools                      = 4
    }
  }

  tag {
    key                 = "Name"
    value               = "${aws_ecs_cluster.cluster.name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}
