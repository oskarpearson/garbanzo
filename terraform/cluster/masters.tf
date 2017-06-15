module "master_1_subnet" {
  source            = "../modules/master_subnet"
  cluster_name      = "${var.cluster_name}"
  master_id         = "1"
  availability_zone = "${var.availability_zones["1"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.1.0/24"
}

module "master_1_node" {
  source             = "../modules/master_node"
  availability_zone  = "${var.availability_zones["1"]}"
  cluster_name       = "${var.cluster_name}"
  kms_key_arn        = "${var.kms_key_arn}"
  master_count       = "3"
  master_id          = "1"
  route53_zone_id    = "${var.route53_zone_id}"
  security_groups    = ["${module.master_security_group.security_group_id}"]
  ssh_key_name       = "${var.ssh_key_name}"
  ssl_key_bucket     = "${var.ssl_key_bucket}"
  subnet_id          = "${module.master_1_subnet.subnet_id}"
  kubernetes_version = "${var.kubernetes_version}"
}

module "master_2_subnet" {
  source            = "../modules/master_subnet"
  cluster_name      = "${var.cluster_name}"
  master_id         = "2"
  availability_zone = "${var.availability_zones["2"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.2.0/24"
}

module "master_2_node" {
  source             = "../modules/master_node"
  availability_zone  = "${var.availability_zones["2"]}"
  cluster_name       = "${var.cluster_name}"
  kms_key_arn        = "${var.kms_key_arn}"
  master_count       = "3"
  master_id          = "2"
  route53_zone_id    = "${var.route53_zone_id}"
  security_groups    = ["${module.master_security_group.security_group_id}"]
  ssh_key_name       = "${var.ssh_key_name}"
  ssl_key_bucket     = "${var.ssl_key_bucket}"
  subnet_id          = "${module.master_2_subnet.subnet_id}"
  kubernetes_version = "${var.kubernetes_version}"
}

module "master_3_subnet" {
  source            = "../modules/master_subnet"
  cluster_name      = "${var.cluster_name}"
  master_id         = "3"
  availability_zone = "${var.availability_zones["3"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.3.0/24"
}

module "master_3_node" {
  source             = "../modules/master_node"
  availability_zone  = "${var.availability_zones["3"]}"
  cluster_name       = "${var.cluster_name}"
  kms_key_arn        = "${var.kms_key_arn}"
  master_count       = "3"
  master_id          = "3"
  route53_zone_id    = "${var.route53_zone_id}"
  security_groups    = ["${module.master_security_group.security_group_id}"]
  ssh_key_name       = "${var.ssh_key_name}"
  ssl_key_bucket     = "${var.ssl_key_bucket}"
  subnet_id          = "${module.master_3_subnet.subnet_id}"
  kubernetes_version = "${var.kubernetes_version}"
}
