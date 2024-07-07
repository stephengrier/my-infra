resource "aws_eip" "imap" {
  domain = "vpc"

  tags = {
    Name = "imap-eip"
  }
}
