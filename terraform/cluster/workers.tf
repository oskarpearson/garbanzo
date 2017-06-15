module "worker_subnet_1" {
  source            = "../modules/worker_subnet"
  cluster_name      = "${var.cluster_name}"
  availability_zone = "${var.availability_zones["1"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.10.0/24"
}

module "worker_subnet_2" {
  source            = "../modules/worker_subnet"
  cluster_name      = "${var.cluster_name}"
  availability_zone = "${var.availability_zones["2"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.11.0/24"
}

module "worker_subnet_3" {
  source            = "../modules/worker_subnet"
  cluster_name      = "${var.cluster_name}"
  availability_zone = "${var.availability_zones["3"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.12.0/24"
}

module "workers" {
  source             = "../modules/workers"
  availability_zones = ["${values(var.availability_zones)}"]
  cluster_name       = "${var.cluster_name}"
  security_groups    = ["${module.workers_security_group.security_group_id}"]
  ssh_key_name       = "${var.ssh_key_name}"
  route53_zone_id    = "${var.route53_zone_id}"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  ssl_key_bucket     = "${var.ssl_key_bucket}"
  kubernetes_version = "${var.kubernetes_version}"

  subnet_ids = [
    "${module.worker_subnet_1.subnet_id}",
    "${module.worker_subnet_2.subnet_id}",
    "${module.worker_subnet_3.subnet_id}",
  ]
}
