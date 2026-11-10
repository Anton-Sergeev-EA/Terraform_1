variable "cloud_id" {
  type = string
}
variable "folder_id" {
  type = string
}
variable "service_account_key_file" {
  type    = string
  default = "~/.config/terraform-netology/authorized_key.json"
}
variable "ssh_public_key_path" {
  type    = string
  default = "~/.config/terraform-netology/id_ed25519.pub"
}
variable "ssh_user" {
  type    = string
  default = "ubuntu"
}
variable "ssh_cidrs" {
  type = list(string)
}
variable "network" {
  type = object({
    name           = string
    zone           = string
    v4_cidr_blocks = list(string)
  })
  default = {
    name           = "terraform-04"
    zone           = "ru-central1-a"
    v4_cidr_blocks = ["10.4.0.0/24"]
  }
}
variable "vm" {
  type = object({
    platform       = string
    image_family   = string
    cores          = number
    memory         = number
    core_fraction  = number
    boot_disk_type = string
    boot_disk_size = number
  })
  default = {
    platform       = "standard-v2"
    image_family   = "ubuntu-2404-lts"
    cores          = 2
    memory         = 1
    core_fraction  = 5
    boot_disk_type = "network-hdd"
    boot_disk_size = 10
  }
}
variable "projects" {
  type = object({
    marketing = string
    analytics = string
  })
  default = {
    marketing = "marketing"
    analytics = "analytics"
  }
}
