resource "aws_security_group" "worker" {
  vpc_id      = "${var.vpc_id}"
  name        = "${var.cluster_name}-worker"
  description = "${var.cluster_name}-worker (Allow worker traffic)"

  tags {
    kubernetes      = "true"
    kubernetes_type = "worker"
    cluster_name    = "${var.cluster_name}"
  }
}

resource "aws_security_group_rule" "ingress_allow_all" {
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.worker.id}"
}

resource "aws_security_group_rule" "egress_allow_all" {
  type        = "egress"
  from_port   = 0
  to_port     = 65535
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.worker.id}"
}

output "security_group_id" {
  value = "${aws_security_group.worker.id}"
}
