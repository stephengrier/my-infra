data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "template_file" "user_data" {
  template = file("${path.module}/files/cloud-init.sh")

  vars = {
    environment    = "${var.environment}"
    region         = "${data.aws_region.current.name}"
    ldap_volume_id = "${aws_ebs_volume.ldap_data.id}"
    imap_volume_id = "${aws_ebs_volume.imap_data.id}"
    eip_id         = "${aws_eip.imap.id}"
  }
}

resource "aws_launch_template" "cluster" {
  name_prefix = "${var.cluster_name}-instance"
  image_id    = data.aws_ami.ami.id
  user_data   = base64encode(data.template_file.user_data.rendered)
  key_name    = "cardno:000605972621"

  iam_instance_profile {
    name = aws_iam_instance_profile.imap_instance.name
  }

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = true
    security_groups             = ["${aws_security_group.imap_instance.id}"]
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = var.cluster_name
  vpc_zone_identifier = ["${element(aws_subnet.public.*.id, 0)}"]
  max_size            = var.number_of_instances
  min_size            = var.number_of_instances
  desired_capacity    = var.number_of_instances

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.cluster.id
        version            = "$Latest"
      }

      override {
        instance_type = "t3a.nano"
      }

      override {
        instance_type = "t3.nano"
      }

      override {
        instance_type = "t2.nano"
      }

      override {
        instance_type = "t3a.micro"
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
    value               = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}
