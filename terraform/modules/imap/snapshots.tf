data "aws_ebs_snapshot" "ldap_data_snapshot" {
  filter {
    name   = "tag:Name"
    values = ["cloud1 ldap data snapshot"]
  }
}

data "aws_ebs_snapshot" "imap_data_snapshot" {
  filter {
    name   = "tag:Name"
    values = ["cloud1 imap data snapshot"]
  }
}
