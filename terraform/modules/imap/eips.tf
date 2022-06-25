resource "aws_eip" "imap" {
  vpc = true

  tags = {
    Name = "imap-eip"
  }
}
