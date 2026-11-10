terraform {
  required_version = "~> 1.12.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.244.0"
    }
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}
provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = pathexpand(var.service_account_key_file)
}
