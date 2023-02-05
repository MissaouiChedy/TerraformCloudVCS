resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "azurerm_network_security_rule" "res-5" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = "KABLAM001-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = "rg-chedy-test"
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-4,
  ]
}
resource "azurerm_resource_group" "res-0" {
  location = "westeurope"
  name     = "rg-chedy-test"
}
resource "azurerm_subnet" "res-8" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "default"
  resource_group_name  = "rg-chedy-test"
  virtual_network_name = "rg-chedy-test-vnet"
  depends_on = [
    azurerm_virtual_network.res-7,
  ]
}
resource "azurerm_linux_virtual_machine" "res-1" {
  admin_password                  = "ignored-as-imported"
  admin_username                  = "chedy"
  disable_password_authentication = false
  location                        = "westeurope"
  name                            = "KABLAM001"
  network_interface_ids           = ["/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/networkInterfaces/kablam00161"]
  resource_group_name             = "rg-chedy-test"
  size                            = "Standard_DS1_v2"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-focal"
    publisher = "canonical"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.res-2,
  ]
}
resource "azurerm_virtual_network" "res-7" {
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  name                = "rg-chedy-test-vnet"
  resource_group_name = "rg-chedy-test"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_network_interface_security_group_association" "res-3" {
  network_interface_id      = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/networkInterfaces/kablam00161"
  network_security_group_id = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/networkSecurityGroups/KABLAM001-nsg"
  depends_on = [
    azurerm_network_interface.res-2,
    azurerm_network_security_group.res-4,
  ]
}
resource "azurerm_network_interface" "res-2" {
  enable_accelerated_networking = true
  location                      = "westeurope"
  name                          = "kablam00161"
  resource_group_name           = "rg-chedy-test"
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/publicIPAddresses/KABLAM001-ip"
    subnet_id                     = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/virtualNetworks/rg-chedy-test-vnet/subnets/default"
  }
  depends_on = [
    azurerm_public_ip.res-6,
    azurerm_subnet.res-8,
  ]
}
resource "azurerm_network_security_group" "res-4" {
  location            = "westeurope"
  name                = "KABLAM001-nsg"
  resource_group_name = "rg-chedy-test"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
resource "azurerm_public_ip" "res-6" {
  allocation_method   = "Static"
  location            = "westeurope"
  name                = "KABLAM001-ip"
  resource_group_name = "rg-chedy-test"
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.res-0,
  ]
}
