module "master_1_subnet" {
  source            = "../modules/master_subnet"
  cluster_name      = "${var.cluster_name}"
  master_id         = "1"
  availability_zone = "${var.availability_zones["1"]}"
  vpc_id            = "${var.vpc_id}"
  cidr_range        = "10.0.1.0/24"
}

module "master_1_node" {
  source            = "../modules/master_node"
  cluster_name      = "${var.cluster_name}"
  master_id         = 1
  availability_zone = "${var.availability_zones["1"]}"
  ssh_key_name      = "${var.ssh_key_name}"
  subnet_id         = "${module.master_1_subnet.subnet_id}"
  security_groups   = ["${module.master_security_group.security_group_id}"]
  load_balancer_ids = ["${module.master_api_elb.master_kubernetes_api_elb_id}"]
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
  source            = "../modules/master_node"
  cluster_name      = "${var.cluster_name}"
  master_id         = 2
  availability_zone = "${var.availability_zones["2"]}"
  ssh_key_name      = "${var.ssh_key_name}"
  subnet_id         = "${module.master_2_subnet.subnet_id}"
  security_groups   = ["${module.master_security_group.security_group_id}"]
  load_balancer_ids = ["${module.master_api_elb.master_kubernetes_api_elb_id}"]
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
  source            = "../modules/master_node"
  cluster_name      = "${var.cluster_name}"
  master_id         = 3
  availability_zone = "${var.availability_zones["3"]}"
  ssh_key_name      = "${var.ssh_key_name}"
  subnet_id         = "${module.master_3_subnet.subnet_id}"
  security_groups   = ["${module.master_security_group.security_group_id}"]
  load_balancer_ids = ["${module.master_api_elb.master_kubernetes_api_elb_id}"]
}
