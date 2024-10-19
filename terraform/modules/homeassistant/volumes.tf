resource "aws_ebs_volume" "ha_data" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  encrypted         = true
  size              = 5
  type              = "gp3"

  tags = {
    Name        = "homeassistant data volume"
    Environment = var.environment
  }
}

resource "aws_ebs_volume" "mosquitto_data" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  encrypted         = true
  size              = 1
  type              = "gp3"

  tags = {
    Name        = "mosquitto data volume"
    Environment = var.environment
  }
}

resource "aws_ebs_volume" "srv_data" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  encrypted         = true
  size              = 1
  type              = "gp3"

  tags = {
    Name        = "srv data volume"
    Environment = var.environment
  }
}
