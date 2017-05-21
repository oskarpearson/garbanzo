resource "aws_iam_instance_profile" "master_instance_profile" {
  name = "${var.cluster_name}-master-${var.number}-instance-profile"

  role = "${aws_iam_role.bootstrap_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "master_instance_running_profile" {
  name = "${var.cluster_name}-master-${var.number}-instance-running-profile"

  role = "${aws_iam_role.running_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "running_role" {
  name = "${var.cluster_name}-master-${var.number}-running-role"

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

resource "aws_iam_policy" "bootstrap_resources" {
  name        = "${var.cluster_name}-master-${var.number}-bootstrap-resources"
  path        = "/"
  description = "${var.cluster_name}-master-${var.number}-bootstrap-resources"

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
                "ec2:DescribeIamInstanceProfileAssociations",
                "ec2:AssociateIamInstanceProfile",
                "ec2:ReplaceIamInstanceProfileAssociation",
                "iam:PassRole"
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
        },
        {
            "Effect": "Allow",
            "Action": [
              "ec2:AssociateAddress"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "bootstrap_resources" {
  name       = "${var.cluster_name}-master-${var.number}-bootstrap-resources"
  policy_arn = "${aws_iam_policy.bootstrap_resources.arn}"

  roles = [
    "${aws_iam_role.bootstrap_role.name}",
  ]
}
