module "master_api_elb" {
  source = "../modules/master_elb"

  cluster_name    = "${var.cluster_name}"
  route53_zone_id = "${var.route53_zone_id}"

  security_groups = [
    "${module.master_security_group.security_group_id}",
  ]

  subnet_ids = [
    "${module.master_1_subnet.subnet_id}",
    "${module.master_2_subnet.subnet_id}",
    "${module.master_3_subnet.subnet_id}",
  ]
}
