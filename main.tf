locals {
  nsg_name       = "${var.virtual_machine_name}-nsg"
  vnet_name      = "${var.virtual_machine_name}-vnet"
  nic_name       = "${var.virtual_machine_name}61"
  public_ip_name = "${var.virtual_machine_name}-ip"
}

resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
}

resource "azurerm_virtual_network" "vnetss" {
  count               = 3
  address_space       = ["10.${count.index}.0.0/16"]
  location            = var.resource_group_location
  name                = "${local.vnet_name}-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_virtual_network" "vnetss2" {
  for_each = {
    "net1" = "9"
    "net2" = "12"
  }
  address_space       = ["10.${each.value}.0.0/16"]
  location            = var.resource_group_location
  name                = "${local.vnet_name}-${each.key}"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

resource "azurerm_network_security_rule" "allow-ssh-nsg-rule" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.main-nsg.name
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
  virtual_network_name = azurerm_virtual_network.vnetss[0].name
  depends_on = [
    azurerm_virtual_network.vnetss,
  ]
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = templatefile("${path.module}/config/cloud-init.yaml", { upgrade_packages = "false" })
  }
}


resource "azurerm_linux_virtual_machine" "main-vm" {
  admin_password                  = var.virtual_machine_password
  admin_username                  = var.virtual_machine_username
  disable_password_authentication = false
  location                        = var.resource_group_location
  name                            = var.virtual_machine_name
  network_interface_ids           = [azurerm_network_interface.main-nic.id]
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_DS1_v2"
  custom_data                     = data.template_cloudinit_config.config.rendered
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
  provisioner "local-exec" {
    command     = "Get-Date > completed.txt"
    interpreter = ["PowerShell", "-Command"]
  }
}

# resource "azurerm_virtual_network" "main-vnet" {
#   address_space       = ["10.0.0.0/16"]
#   location            = var.resource_group_location
#   name                = local.vnet_name
#   resource_group_name = azurerm_resource_group.rg.name
#   depends_on = [
#     azurerm_resource_group.rg,
#   ]
# }
resource "azurerm_network_interface_security_group_association" "main-nsg-nic-association" {
  network_interface_id      = azurerm_network_interface.main-nic.id
  network_security_group_id = azurerm_network_security_group.main-nsg.id
  depends_on = [
    azurerm_network_interface.main-nic,
    azurerm_network_security_group.main-nsg,
  ]
}
resource "azurerm_network_interface" "main-nic" {
  enable_accelerated_networking = true
  location                      = var.resource_group_location
  name                          = local.nic_name
  resource_group_name           = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main-publicip.id
    subnet_id                     = azurerm_subnet.main-subnet.id
  }
  depends_on = [
    azurerm_public_ip.main-publicip,
    azurerm_subnet.main-subnet,
  ]
}
resource "azurerm_network_security_group" "main-nsg" {
  location            = var.resource_group_location
  name                = local.nsg_name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_public_ip" "main-publicip" {
  allocation_method   = "Static"
  location            = var.resource_group_location
  name                = local.public_ip_name
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

data "azurerm_virtual_machine" "vms" {
  name                = var.virtual_machine_name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_linux_virtual_machine.main-vm,
  ]
}
