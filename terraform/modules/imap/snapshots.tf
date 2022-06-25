data "aws_ebs_volume" "cloud1_ldap_data" {
  filter {
    name   = "tag:Name"
    values = ["cloud1 ldap data"]
  }
}

data "aws_ebs_volume" "cloud1_imap_data" {
  filter {
    name   = "tag:Name"
    values = ["cloud1 imap data"]
  }
}

resource "aws_ebs_snapshot" "ldap_data_snapshot" {
  volume_id   = "${data.aws_ebs_volume.cloud1_ldap_data.id}"
  description = "cloud1 ldap data snapshot"

  tags = {
    Name = "cloud1 ldap data snapshot"
  }
}

resource "aws_ebs_snapshot" "imap_data_snapshot" {
  volume_id   = "${data.aws_ebs_volume.cloud1_imap_data.id}"
  description = "cloud1 imap data snapshot"

  tags = {
    Name = "cloud1 imap data snapshot"
  }
}
