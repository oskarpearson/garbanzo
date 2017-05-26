resource "aws_ebs_volume" "main" {
  availability_zone = "${var.availability_zone}"
  size              = 20
  type              = "gp2"

  tags {
    Name         = "${var.cluster_name}-master-${var.master_id}-main"
    type         = "main"
    kubernetes   = true
    cluster_name = "${var.cluster_name}"
    master_id    = "${var.master_id}"
  }
}

resource "aws_ebs_volume" "events" {
  availability_zone = "${var.availability_zone}"
  size              = 20
  type              = "gp2"

  tags {
    Name         = "${var.cluster_name}-master-${var.master_id}-events"
    type         = "events"
    kubernetes   = true
    cluster_name = "${var.cluster_name}"
    master_id    = "${var.master_id}"
  }
}
