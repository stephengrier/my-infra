resource "aws_ebs_volume" "ldap_data" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  snapshot_id       = data.aws_ebs_snapshot.ldap_data_snapshot.id
  encrypted         = true

  tags = {
    Name        = "ldap data volume"
    Environment = "${var.environment}"
  }
}

resource "aws_ebs_volume" "imap_data" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  snapshot_id       = data.aws_ebs_snapshot.imap_data_snapshot.id
  encrypted         = true

  tags = {
    Name        = "imap data volume"
    Environment = "${var.environment}"
  }
}
