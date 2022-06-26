resource "aws_iam_role" "imap_instance" {
  name = "${var.cluster_name}-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.imap_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "attach_volume" {
  name        = "attach_volume_policy"
  path        = "/"
  description = "An IAM policy that allows instances to attach specific EBS volumes"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AttachVolume"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:instance/*",
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:volume/${aws_ebs_volume.ldap_data.id}",
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:volume/${aws_ebs_volume.imap_data.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_volume" {
  role       = aws_iam_role.imap_instance.name
  policy_arn = aws_iam_policy.attach_volume.arn
}

resource "aws_iam_policy" "associate_address" {
  name        = "associate_address_policy"
  path        = "/"
  description = "An IAM policy that allows instances to associate elastic IP addresses"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AssociateAddress"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "associate_address" {
  role       = aws_iam_role.imap_instance.name
  policy_arn = aws_iam_policy.associate_address.arn
}

resource "aws_iam_instance_profile" "imap_instance" {
  name = "${var.cluster_name}-instance-profile"
  role = aws_iam_role.imap_instance.name
}
