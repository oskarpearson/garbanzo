resource "aws_iam_instance_profile" "worker_instance_profile" {
  name = "${var.cluster_name}-worker-boot-profile"

  role = "${aws_iam_role.bootstrap_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "worker_instance_running_profile" {
  name = "${var.cluster_name}-worker-running-profile"

  role = "${aws_iam_role.running_role.name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "running_role" {
  name = "${var.cluster_name}-worker-running-role"

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
  name = "${var.cluster_name}-worker-bootstrap-role"

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
  name        = "${var.cluster_name}-worker-bootstrap-resources"
  path        = "/"
  description = "${var.cluster_name}-worker-bootstrap-resources"

  # FIXME - need to limit this...
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect": "Allow",
          "Action": [ "ec2:*" ],
          "Resource": [ "*" ]
        },
        {
          "Effect": "Allow",
          "Action": [ "elasticloadbalancing:*" ],
          "Resource": [ "*" ]
        },
        {
          "Effect": "Allow",
          "Action": [ "route53:*" ],
          "Resource": [ "*" ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeIamInstanceProfileAssociations"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AssociateIamInstanceProfile",
                "ec2:ReplaceIamInstanceProfileAssociation"
            ],
            "Resource": "arn:aws:ec2:*:*:instance/*",
            "Condition": {
                "StringEquals": {
                    "ec2:ResourceTag/Name": "${var.cluster_name}-workers"
                }
            }
        },
        {
          "Effect": "Allow",
          "Action": [
              "s3:GetObject"
          ],
          "Resource": [
             "arn:aws:s3:::${var.ssl_key_bucket}/*"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "bootstrap_resources" {
  name       = "${var.cluster_name}-worker-bootstrap-resources"
  policy_arn = "${aws_iam_policy.bootstrap_resources.arn}"

  roles = [
    "${aws_iam_role.bootstrap_role.name}",
  ]
}
