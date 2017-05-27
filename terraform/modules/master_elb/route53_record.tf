resource "aws_route53_record" "api_alias" {
  zone_id = "${var.route53_zone_id}"
  name    = "api.${var.cluster_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.master_kubernetes_api.dns_name}"
    zone_id                = "${aws_elb.master_kubernetes_api.zone_id}"
    evaluate_target_health = false
  }
}
