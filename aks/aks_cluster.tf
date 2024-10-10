
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "${azurerm_resource_group.aks_rg.name}-cluster"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "${azurerm_resource_group.aks_rg.name}-cluster"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group = "${azurerm_resource_group.aks_rg.name}-nrg"
    
  default_node_pool {
    
    name                 = "systempool"
    vm_size              = "Standard_DS2_v2"    
    orchestrator_version = data.azurerm_kubernetes_service_versions.current.latest_version
    node_count       =    1
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    node_labels = {
      "nodepool-type"    = "system"
      "environment"      = "dev"
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
    } 
   tags = {
      "nodepool-type"    = "system"
      "environment"      = "dev"
      "nodepoolos"       = "linux"
      "app"              = "system-apps" 
   } 
  }

# Identity (System Assigned or Service Principal)
  identity {
    type = "SystemAssigned"
  }

# Added June 2023
oms_agent {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
}
# Add On Profiles
#  addon_profile {
#    azure_policy {enabled =  true}
#    oms_agent {
#      enabled =  true
#      log_analytics_workspace_id = azurerm_log_analytics_workspace.insights.id
#    }
#  }

# RBAC and Azure AD Integration Block
#  role_based_access_control {
#    enabled = true
#    azure_active_directory {
#      managed = true
#      admin_group_object_ids = [azuread_group.aks_administrators.id]
#    }
#  }
# Added June 2023


# Windows Profile
  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

# Linux Profile
  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwRm6Mi9FABI24+A3wwdrbWfvzGTYpwOxXlfV4y1f/clZXh79wDZtuzKvrZGsY/6c1Q43Cx9+FbQmBgylwhYBJ9kibCwqww6dUE6laZQpwgrW0K9DDsQDLEfkcFvkEqJWCqRh8MR4JH85nF5glgFkOH1W/4sCy7GPn18mqJbp/cbOLAeC7618LJtpV5f92yC32mMj3tPJTplmHnNtUfMhdlOW90JgzVReF/TfuM8n/+8EjM8ezsOuFt6AnLticdSCGVkLgjgW5mM1KvTH4m/8/WBtRcw4WyKU586+3ookMPV/5FAeQSpVYVSxolGF3/rH5Fx4feN0EZouSecLSAFiX rsa-key-20241003"
    }
  }

# Network Profile
  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  tags = {
    Environment = "dev"
  }
}