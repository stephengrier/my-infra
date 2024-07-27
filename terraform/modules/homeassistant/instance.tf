data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
}

resource "aws_launch_template" "ha_instance" {
  name_prefix = "${local.resource_name}-ha-instance"
  image_id    = data.aws_ami.ami.id
  key_name    = var.instance_key_name
  user_data = base64encode(templatefile(
    "${path.module}/files/cloud-init.sh",
    {
      environment         = var.environment,
      region              = data.aws_region.current.name,
      ha_volume_id        = aws_ebs_volume.ha_data.id,
      mosquitto_volume_id = aws_ebs_volume.mosquitto_data.id,
      eip_id              = aws_eip.ha_instance.id
      server_name         = var.server_name
      mqtt_server_name    = var.mqtt_server_name
      letsencrypt_email   = var.letsencrypt_email
      certbot_extra_args  = var.certbot_extra_args
    }
  ))

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance.arn
  }

  network_interfaces {
    delete_on_termination       = true
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ha_instance.id]
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${local.resource_name}-asg"
  vpc_zone_identifier = [element(aws_subnet.public.*.id, 0)]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  mixed_instances_policy {
    instances_distribution {
      on_demand_base_capacity                  = 0
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "price-capacity-optimized"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.ha_instance.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = local.spot_instance_types

        content {
          instance_type = override.value
        }
      }
    }
  }

  tag {
    key                 = "Name"
    value               = "${local.resource_name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}
