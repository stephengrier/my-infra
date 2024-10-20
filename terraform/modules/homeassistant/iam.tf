resource "aws_iam_role" "instance" {
  name = "${local.resource_name}-instance-role"

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

resource "aws_iam_role_policy_attachment" "instance_ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "attach_volume" {
  name        = "${local.resource_name}_attach_volume_policy"
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
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:volume/${aws_ebs_volume.ha_data.id}",
        "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.account.account_id}:volume/${aws_ebs_volume.srv_data.id}"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach_volume" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.attach_volume.arn
}

resource "aws_iam_policy" "associate_address" {
  name        = "${local.resource_name}_associate_address_policy"
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
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.associate_address.arn
}

resource "aws_iam_instance_profile" "instance" {
  name = "${local.resource_name}-instance-profile"
  role = aws_iam_role.instance.name
}
