output "instances" {
  value = {
    marketing = {
      ip = one(module.marketing_vm.external_ip_address)
      id = one(module.marketing_vm.all).id
    }
    analytics = {
      ip = one(module.analytics_vm.external_ip_address)
      id = one(module.analytics_vm.all).id
    }
  }
}
