resource "random_string" "random-name" {
  length  = 10
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "azurerm_resource_group" "rg-group" {
  name     = "autoscaling-demo-${random_string.random-name.result}"
  location = var.location
}

resource "azurerm_resource_group" "rg" {
  for_each = tomap({
    a_group       = "eastus"
    another_group = "westus2"
  })
  name     = each.key
  location = each.value
}