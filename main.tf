## Create Resource Group ##
resource "azurerm_resource_group" "rgtest" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

## Create VNet ##
resource "azurerm_virtual_network" "vnet_test" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name

  tags = {
    environment = "Test"
  }

}

## Create Subnet ##
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rgtest.name
  virtual_network_name = azurerm_virtual_network.vnet_test.name
  address_prefix       = "10.0.1.0/24"

}

## Create Public IP ##
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "Test"
  }

}

## Create Network Security Group and Rules ##
resource "azurerm_network_security_group" "nsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name

  security_rule {
    name                       = "SSH"
    priority                   = "1001"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Apache"
    priority                   = "1002"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Test"
  }

}

## Create Network Interface ##
resource "azurerm_network_interface" "nic" {
  name                = var.network_interface_name
  location            = azurerm_resource_group.rgtest.location
  resource_group_name = azurerm_resource_group.rgtest.name

  ip_configuration {
    name                          = "nicconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = "Test"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

## Create Virtual Machine ##
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = var.linux_virtual_machine_name
  location              = azurerm_resource_group.rgtest.location
  resource_group_name   = azurerm_resource_group.rgtest.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  computer_name         = "ubuntutest"
  admin_username        = "build"
  size                  = "Standard_B2ats_v2"

  custom_data = filebase64("customdata.tpl")

  os_disk {
    name                 = "ubuntutest_osDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "build"
    public_key = file("~/.ssh/build.pub")
  }


  disable_password_authentication = true

  tags = {
    environment = "Test"
  }

}
