provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "maleo_rg" {
  name     = "maleo-resource-group"
  location = "West Europe"
}

resource "azurerm_virtual_network" "maleo_vnet" {
  name                = "maleo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.maleo_rg.location
  resource_group_name = azurerm_resource_group.maleo_rg.name
}

resource "azurerm_subnet" "maleo_subnet" {
  name                 = "maleo-subnet"
  resource_group_name  = azurerm_resource_group.maleo_rg.name
  virtual_network_name = azurerm_virtual_network.maleo_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "maleo_nic" {
  name                = "maleo-nic"
  location            = azurerm_resource_group.maleo_rg.location
  resource_group_name = azurerm_resource_group.maleo_rg.name

  ip_configuration {
    name                          = "maleo-nic-config"
    subnet_id                     = azurerm_subnet.maleo_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "maleo_public_ip" {
  name                = "maleo-public-ip"
  location            = azurerm_resource_group.maleo_rg.location
  resource_group_name = azurerm_resource_group.maleo_rg.name
  allocation_method   = "Static"

  tags = {
    environment = "maleo"
  }
}

resource "azurerm_network_security_group" "maleo_nsg" {
  name                = "maleo-nsg"
  location            = azurerm_resource_group.maleo_rg.location
  resource_group_name = azurerm_resource_group.maleo_rg.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "maleo_nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.maleo_nic.id
  network_security_group_id = azurerm_network_security_group.maleo_nsg.id
}

resource "azurerm_virtual_machine" "maleo_vm" {
  name                  = "maleo-vm"
  location              = azurerm_resource_group.maleo_rg.location
  resource_group_name   = azurerm_resource_group.maleo_rg.name
  network_interface_ids = [azurerm_network_interface.maleo_nic.id]
  vm_size               = "Standard_Bs1"

  storage_image_reference {
   id = "maleo-image"
  }

  storage_os_disk {
    name              = "maleo-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "maleo-vm"
    admin_username = "maleoadmin"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "maleo"
  }
}
