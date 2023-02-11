variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  description = "Name of the resource group."
}



resource "azurerm_virtual_network" "vnetss" {
  count               = 3
  address_space       = ["10.${count.index}.0.0/16"]
  location            = var.resource_group_location
  name                = "modulatedvnet-${count.index}"
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnetss2" {
  for_each = {
    "net1" = "9"
    "net2" = "12"
  }
  address_space       = ["10.${each.value}.0.0/16"]
  location            = var.resource_group_location
  name                = "modulatedvnet-${each.key}"
  resource_group_name = var.resource_group_name
}



output "vnet_name" {
  value = azurerm_virtual_network.vnetss[0].name
}
