resource "aws_autoscaling_group" "workers" {
  availability_zones = ["${var.availability_zones}"]
  name               = "${var.cluster_name}-workers"

  desired_capacity = "${var.desired_capacity}"
  max_size         = "${var.min_size}"
  min_size         = "${var.max_size}"

  launch_configuration = "${aws_launch_configuration.workers.name}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]

  tag {
    key   = "Name"
    value = "${var.cluster_name}-workers"

    # Don't copy to the instance, otherwise every host has the same name
    propagate_at_launch = false
  }

  tag {
    key                 = "kubernetes"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "cluster_name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server-${var.kubernetes_version} - *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["760961392368"] # Garbanzo Project
}

data "aws_route53_zone" "zone" {
  zone_id = "${var.route53_zone_id}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars {
    cluster_name        = "${var.cluster_name}"
    domain_name         = "${var.cluster_name}.${replace(data.aws_route53_zone.zone.name, "/.$$/", "")}"
    route53_zone_id     = "${var.route53_zone_id}"
    hostname            = "worker"
    ssl_key_bucket      = "${var.ssl_key_bucket}"
    running_profile_arn = "${aws_iam_instance_profile.worker_instance_running_profile.arn}"
  }
}

resource "aws_launch_configuration" "workers" {
  name_prefix   = "${var.cluster_name}-workers-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"

  associate_public_ip_address = "true"

  security_groups = ["${var.security_groups}"]

  iam_instance_profile = "${aws_iam_instance_profile.worker_instance_profile.id}"

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}
