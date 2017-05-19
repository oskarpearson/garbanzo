module "master_1_subnet" {
  source = "../modules/master_subnet"

  vpc_id     = "${var.vpc_id}"
  cidr_range = "10.0.0.0/24"
}

module "master_1_node" {
  source = "../modules/master_node"

  cluster_name      = "${var.cluster_name}"
  number            = 1
  availability_zone = "${var.availability_zones["1"]}"
  ssh_key_name      = "${var.ssh_key_name}"

  security_groups = ["${module.master_security_group.security_group_id}"]
}
