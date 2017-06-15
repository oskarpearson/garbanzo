resource "aws_route53_record" "api_alias" {
  zone_id = "${var.route53_zone_id}"
  name    = "api.${var.cluster_name}"
  type    = "A"
  ttl     = 10

  records = [
    "${module.master_1_node.master_elastic_ip}",
    "${module.master_2_node.master_elastic_ip}",
    "${module.master_3_node.master_elastic_ip}",
  ]
}
