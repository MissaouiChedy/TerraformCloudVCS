resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "azurerm_network_security_rule" "allow-ssh-nsg-rule" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = "KABLAM001-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.main-nsg,
  ]
}

resource "azurerm_subnet" "main-subnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = "rg-chedy-test-vnet"
  depends_on = [
    azurerm_virtual_network.main-vnet,
  ]
}
resource "azurerm_linux_virtual_machine" "res-1" {
  admin_password                  = "ignored-as-imported"
  admin_username                  = "chedy"
  disable_password_authentication = false
  location                        = "westeurope"
  name                            = "KABLAM001"
  network_interface_ids           = ["/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/networkInterfaces/kablam00161"]
  resource_group_name             = azurerm_resource_group.rg.name
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
    azurerm_network_interface.main-nic,
  ]
}
resource "azurerm_virtual_network" "main-vnet" {
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  name                = "rg-chedy-test-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_network_interface_security_group_association" "main-nsg-nic-association" {
  network_interface_id      = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/networkInterfaces/kablam00161"
  network_security_group_id = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/networkSecurityGroups/KABLAM001-nsg"
  depends_on = [
    azurerm_network_interface.main-nic,
    azurerm_network_security_group.main-nsg,
  ]
}
resource "azurerm_network_interface" "main-nic" {
  enable_accelerated_networking = true
  location                      = "westeurope"
  name                          = "kablam00161"
  resource_group_name           = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/publicIPAddresses/KABLAM001-ip"
    subnet_id                     = "/subscriptions/07093206-6009-4977-9d2c-7b88cda14e92/resourceGroups/rg-chedy-test/providers/Microsoft.Network/virtualNetworks/rg-chedy-test-vnet/subnets/default"
  }
  depends_on = [
    azurerm_public_ip.main-publicip,
    azurerm_subnet.main-subnet,
  ]
}
resource "azurerm_network_security_group" "main-nsg" {
  location            = "westeurope"
  name                = "KABLAM001-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_public_ip" "main-publicip" {
  allocation_method   = "Static"
  location            = "westeurope"
  name                = "KABLAM001-ip"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
