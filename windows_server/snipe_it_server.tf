resource "azurerm_resource_group" "snipe_it_rg" {
  location = var.resource_group_location
  name     = "${random_pet.prefix.id}-rg"
}

resource "azurerm_virtual_network" "snipe_network" {
  name                = "${random_pet.prefix.id}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.snipe_it_rg.location
  resource_group_name = azurerm_resource_group.snipe_it_rg.name
}

resource "azurerm_subnet" "snipe_subnet" {
  name                 = "${random_pet.prefix.id}-subnet"
  resource_group_name  = azurerm_resource_group.snipe_it_rg.name
  virtual_network_name = azurerm_virtual_network.snipe_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "snipe_public_ip" {
  name                = "${random_pet.prefix.id}-public-ip"
  location            = azurerm_resource_group.snipe_it_rg.location
  resource_group_name = azurerm_resource_group.snipe_it_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "snipe_nsg" {
  name                = "${random_pet.prefix.id}-nsg"
  location            = azurerm_resource_group.snipe_it_rg.location
  resource_group_name = azurerm_resource_group.snipe_it_rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
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

resource "azurerm_network_interface" "snipe_nic" {
  name                = "${random_pet.prefix.id}-nic"
  location            = azurerm_resource_group.snipe_it_rg.location
  resource_group_name = azurerm_resource_group.snipe_it_rg.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.snipe_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.snipe_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "snipe_sec_group_association" {
  network_interface_id      = azurerm_network_interface.snipe_nic.id
  network_security_group_id = azurerm_network_security_group.snipe_nsg.id
}

resource "azurerm_storage_account" "snipe_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = azurerm_resource_group.snipe_it_rg.location
  resource_group_name      = azurerm_resource_group.snipe_it_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "random_id" "random_id" {
  keepers = {
    resource_group = azurerm_resource_group.snipe_it_rg.name
  }

  byte_length = 8
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}