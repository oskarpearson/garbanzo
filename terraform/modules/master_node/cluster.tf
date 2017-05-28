resource "aws_autoscaling_group" "master" {
  depends_on = [
    "aws_ebs_volume.main",
    "aws_ebs_volume.events",
  ]

  availability_zones = ["${var.availability_zone}"]
  name               = "${var.cluster_name}-master-${var.master_id}"
  max_size           = 1
  min_size           = 1

  # health_check_grace_period = 300
  # health_check_type         = "ELB"
  desired_capacity = 1

  launch_configuration = "${aws_launch_configuration.master.name}"
  load_balancers       = ["${var.load_balancer_ids}"]
  vpc_zone_identifier  = ["${var.subnet_id}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-master-${var.master_id}"
    propagate_at_launch = true
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

  tag {
    key                 = "master_id"
    value               = "${var.master_id}"
    propagate_at_launch = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*ubuntu-xenial-16.04-amd64-server-v1.6.4 - *"]
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
    elastic_ip          = "${aws_eip.master.public_ip}"
    hostname            = "master-${var.master_id}"
    master_count        = "${var.master_count}"
    master_id           = "${var.master_id}"
    running_profile_arn = "${aws_iam_instance_profile.master_instance_running_profile.arn}"
    ssl_key_bucket      = "${var.ssl_key_bucket}"
  }
}

resource "aws_launch_configuration" "master" {
  name_prefix   = "${var.cluster_name}-master-${var.master_id}-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"

  # FIXME: We currently need a temporary public IP address for the boot process.
  # This is swapped out with the aws_eip.master.public_ip by the Userdata
  associate_public_ip_address = "true"

  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"

  security_groups = ["${var.security_groups}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}
