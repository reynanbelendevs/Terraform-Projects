terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.2"
    }
  }
  required_version = ">= 1.1.0"
  cloud { 
    organization = "nanGroups" 
    workspaces { 
      name = "learn-terraform-azure" 
    } 
  } 
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags = {
    "Environment" = "Terraform Getting Started"
    "Team"        = "DevOps"
  }
}

//Virtual Machine
resource "azurerm_virtual_machine" "demo-instance-1" {
  name                  = "${var.prefix}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.demo-instance-1.id]
  vm_size               = "Standard_B1s"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "demo-instance"
    admin_username = "demo"
    #admin_password = "..."
    custom_data = base64encode("#!/bin/bash\n\napt-get update && apt-get install -y net-tools")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("mykey.pub")
      path     = "/home/demo/.ssh/authorized_keys"
    }
  }
}
//network interface
resource "azurerm_network_interface" "demo-instance-1" {
  name                = "${var.prefix}-instance1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "instance1"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo-instance-1.id
  }
}
//public ip connection to network interface
resource "azurerm_public_ip" "demo-instance-1" {
  name                = "instance1-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}
resource "azurerm_network_interface_security_group_association" "demo-instance-1" {
  network_interface_id      = azurerm_network_interface.demo-instance-1.id
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
}

resource "azurerm_application_security_group" "demo-instance-group" {
  name                = "internet-facing"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_interface_application_security_group_association" "demo-instance-group" {
  network_interface_id          = azurerm_network_interface.demo-instance-1.id 
  application_security_group_id = azurerm_application_security_group.demo-instance-group.id
}
#2nd Vm Internally
resource "azurerm_virtual_machine" "demo-instance-2" {
  name                  = "${var.prefix}-vm-2"
  location              = var.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.demo-instance-2.id]
  vm_size               = "Standard_B1s"

  # this is a demo instance, so we can delete all data on termination
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "demo-instance"
    admin_username = "demo"
    custom_data    = base64encode("#!/bin/bash\n\napt-get update && apt-get install -y net-tools")
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = file("mykey.pub")
      path     = "/home/demo/.ssh/authorized_keys"
    }
  }
}
resource "azurerm_network_interface" "demo-instance-2" {
  name                = "${var.prefix}-instance2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "instance2"
    subnet_id                     = azurerm_subnet.demo-internal-1.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface_security_group_association" "demo-instance-2" {
  network_interface_id      = azurerm_network_interface.demo-instance-2.id
  network_security_group_id = azurerm_network_security_group.internal-facing.id
}