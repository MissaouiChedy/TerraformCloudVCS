output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_ip_address" {
  value = azurerm_public_ip.main-publicip.ip_address
}

output "virtual_machine_name" {
  value = data.azurerm_virtual_machine.vms.name
}