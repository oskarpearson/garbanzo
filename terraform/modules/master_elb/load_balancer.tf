resource "aws_elb" "master_kubernetes_api" {
  name            = "lb-${var.cluster_name}-master-api"
  security_groups = ["${var.security_groups}"]
  subnets         = ["${var.subnet_ids}"]

  listener {
    instance_port     = "${var.kubernetes_api_port}"
    instance_protocol = "TCP"
    lb_port           = "${var.kubernetes_api_port}"
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:${var.kubernetes_api_port}"
    interval            = 30
  }

  connection_draining = true

  tags {
    Name         = "${var.cluster_name}-kubernetes-api"
    kubernetes   = true
    cluster_name = "${var.cluster_name}"
  }
}

output "master_kubernetes_api_elb_id" {
  value = "${aws_elb.master_kubernetes_api.id}"
}
