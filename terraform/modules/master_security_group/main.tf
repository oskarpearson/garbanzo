resource "aws_security_group" "master" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.cluster_name}-master"
  description = "${var.cluster_name}-master (Allow master traffic)"

  tags {
    kubernetes      = "true"
    kubernetes_type = "master"
    cluster_name    = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "ingress_allow_all" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.master.id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.master.id}"
}

output "security_group_id" {
  value = "${aws_security_group.master.id}"
}
