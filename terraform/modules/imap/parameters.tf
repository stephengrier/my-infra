locals {
  imapd_conf_content = file("${path.module}/files/config/${var.environment}/imapd.conf")
  cyrus_conf_content = file("${path.module}/files/config/${var.environment}/cyrus.conf")
}

resource "aws_ssm_parameter" "imapd_conf_content" {
  name        = "/imap/config/${var.environment}/imapd_conf"
  description = "Content of the imapd.conf config file"
  type        = "SecureString"
  value       = local.imapd_conf_content

  tags = {
    environment = "${var.environment}"
  }
}

resource "aws_ssm_parameter" "cyrus_conf_content" {
  name        = "/imap/config/${var.environment}/cyrus_conf"
  description = "Content of the cyrus.conf config file"
  type        = "SecureString"
  value       = local.cyrus_conf_content

  tags = {
    environment = "${var.environment}"
  }
}
