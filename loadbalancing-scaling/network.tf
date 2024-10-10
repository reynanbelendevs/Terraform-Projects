resource "azurerm_virtual_network" "vnet" {
  name                = "load-virtual-net"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-group.name
  address_space       = ["10.0.0.0/16"]

}
resource "azurerm_subnet" "load-subnet-1" {
  name                 = "load-subnet-1"
  resource_group_name  = azurerm_resource_group.rg-group.name
  address_prefixes     = ["10.0.0.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_network_security_group" "load-instance" {
  name                = "load-instance-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-group.name
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
  security_rule {
    name                       = "SSH"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.ssh-source-address
    destination_address_prefix = "*"
  }
}