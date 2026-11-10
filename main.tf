module "vpc_dev" {
  source = "./vpc"

  name           = var.network.name
  zone           = var.network.zone
  v4_cidr_blocks = var.network.v4_cidr_blocks
}

data "template_file" "cloudinit" {
  template = file("${path.module}/cloud-init.yml")
  vars = {
    ssh_user = var.ssh_user
    ssh_keys = jsonencode([trimspace(file(pathexpand(var.ssh_public_key_path)))])
  }
}

resource "yandex_vpc_security_group" "ssh" {
  name       = "${var.network.name}-ssh"
  network_id = module.vpc_dev.subnet.network_id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = var.ssh_cidrs
  }
  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

module "marketing_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=a230c799304c20f15f0ad761ed704e46f534a821"

  instance_name          = var.projects.marketing
  labels                 = { project = var.projects.marketing }
  network_id             = module.vpc_dev.subnet.network_id
  subnet_zones           = [module.vpc_dev.subnet.zone]
  subnet_ids             = [module.vpc_dev.subnet.id]
  security_group_ids     = [yandex_vpc_security_group.ssh.id]
  platform               = var.vm.platform
  image_family           = var.vm.image_family
  instance_cores         = var.vm.cores
  instance_memory        = var.vm.memory
  instance_core_fraction = var.vm.core_fraction
  boot_disk_type         = var.vm.boot_disk_type
  boot_disk_size         = var.vm.boot_disk_size
  preemptible            = true
  public_ip              = true
  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = "1"
  }
}

module "analytics_vm" {
  source = "git::https://github.com/udjin10/yandex_compute_instance.git?ref=a230c799304c20f15f0ad761ed704e46f534a821"

  instance_name          = var.projects.analytics
  labels                 = { project = var.projects.analytics }
  network_id             = module.vpc_dev.subnet.network_id
  subnet_zones           = [module.vpc_dev.subnet.zone]
  subnet_ids             = [module.vpc_dev.subnet.id]
  security_group_ids     = [yandex_vpc_security_group.ssh.id]
  platform               = var.vm.platform
  image_family           = var.vm.image_family
  instance_cores         = var.vm.cores
  instance_memory        = var.vm.memory
  instance_core_fraction = var.vm.core_fraction
  boot_disk_type         = var.vm.boot_disk_type
  boot_disk_size         = var.vm.boot_disk_size
  preemptible            = true
  public_ip              = true
  metadata = {
    user-data          = data.template_file.cloudinit.rendered
    serial-port-enable = "1"
  }
}
