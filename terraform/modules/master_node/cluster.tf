resource "aws_autoscaling_group" "master" {
  availability_zones = ["${var.availability_zone}"]
  name               = "${var.cluster_name}-master-${var.number}"
  max_size           = 1
  min_size           = 1

  # health_check_grace_period = 300
  # health_check_type         = "ELB"
  desired_capacity = 1

  launch_configuration = "${aws_launch_configuration.master.name}"

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-master-${var.number}"
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
    key                 = "master_number"
    value               = "${var.number}"
    propagate_at_launch = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.tpl")}"

  vars {
    elastic_ip          = "${aws_eip.master.public_ip}"
    running_profile_arn = "${aws_iam_instance_profile.master_instance_running_profile.arn}"
  }
}

resource "aws_launch_configuration" "master" {
  name          = "${var.cluster_name}-master-${var.number}"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.ssh_key_name}"

  iam_instance_profile = "${aws_iam_instance_profile.master_instance_profile.id}"

  security_groups = ["${var.security_groups}"]

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}
