resource "aws_security_group" "master" {
  name        = "${var.cluster_name}-master"
  description = "${var.cluster_name}-master (Allow master traffic)"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    kubernetes   = "true"
    cluster_name = "${var.cluster_name}"
  }
}

output "security_group_id" {
  value = "${aws_security_group.master.id}"
}
