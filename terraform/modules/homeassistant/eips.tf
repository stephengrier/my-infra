resource "aws_eip" "ha_instance" {
  domain = "vpc"

  tags = {
    Name = "ha-instance-eip"
  }
}
