resource "azurerm_linux_virtual_machine_scale_set" "scale-set" {
  name                = "mytestscaleset-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-group.name
  automatic_os_upgrade_policy {
    enable_automatic_os_upgrade = false
    disable_automatic_rollback  = false
  }
  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }
  upgrade_mode = "Rolling"

  health_probe_id = azurerm_lb_probe.probe.id

  zones = var.zones

  instances = 2
  sku       = "Standard_B1s"
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  admin_username       = "nan"
  computer_name_prefix = "nan"
  custom_data          = base64encode("#!/bin/bash\n\napt-get update && apt-get install -y nginx && systemctl enable nginx && systemctl start nginx")
  data_disk {
    lun                  = 0
    caching              = "ReadWrite"
    create_option        = "Empty"
    disk_size_gb         = 10
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "nan"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDnJB/xHHTl3nPj39WbPGvQIzV/uHTrS2RLgwuent+XsqNKQSQg4y2KAoTvgear0rGdklcNukrHp2JM0lRg6Ch/BUNm0imjL97FzotlkWDAWlEJK08tQc5YGQDdgEtXWbhB/tRe8RbSZ+55gntojJhqVulmmIFWNRL7tEl7V58RYZkXwTbOAfhkSoFpCyp1O4hHr/Kr3X8kQ8PBqKqFYtOhzExzpF8quSZtAXdn6dOHmaX0PduQERRTX/mLj7cx7xc1qfzdMJ5z1fpNCEZepuT10vb2GRzuV1dZtHQAq+4zZZROkpk76djNr3eZ1qFahQPr1AwR24rKLp9+wgRGV2St rsa-key-20241002"
  }
  network_interface {
    name                      = "networkprofile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.load-instance.id

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.load-subnet-1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
}