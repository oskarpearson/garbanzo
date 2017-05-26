resource "aws_security_group" "master_kubernetes_api" {
  name        = "${var.cluster_name}-api"
  description = "${var.cluster_name}-api"

  ingress {
    from_port   = "${var.kubernetes_api_port}"
    to_port     = "${var.kubernetes_api_port}"
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    kubernetes       = "true"
    kubernetest_type = "load_balancer"
    cluster_name     = "${var.cluster_name}"
  }
}
