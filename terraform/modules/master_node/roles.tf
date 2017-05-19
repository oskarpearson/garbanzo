resource "aws_iam_instance_profile" "master_instance_profile" {
  name = "${var.cluster_name}-master-${var.number}-instance-profile"

  role = "${aws_iam_role.bootstrap_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "bootstrap_role" {
  name = "${var.cluster_name}-master-${var.number}-bootstrap-role"

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

resource "aws_iam_policy" "bootstrap_volumes" {
  name        = "${var.cluster_name}-master-${var.number}-bootstrap-volumes"
  path        = "/"
  description = "${var.cluster_name}-master-${var.number}-bootstrap-volumes"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeVolumes"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Name": "${var.cluster_name}-master-${var.number}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume"
            ],
            "Resource": "arn:aws:ec2:*:*:volume/*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "bootstrap_volumes" {
  name       = "${var.cluster_name}-master-${var.number}-bootstrap-volumes"
  policy_arn = "${aws_iam_policy.bootstrap_volumes.arn}"

  roles = [
    "${aws_iam_role.bootstrap_role.name}",
  ]
}
