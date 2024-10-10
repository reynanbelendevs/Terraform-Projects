resource "azurerm_lb" "load-balancer" {
  name                = "system-loadbalancer"
  sku                 = "Basic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-group.name

  frontend_ip_configuration {
    name                 = "LoadBalancerIPAddress"
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }

}

resource "azurerm_public_ip" "public-ip" {
  name                = "load-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-group.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.rg-group.name
  sku                 = "Basic"
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  loadbalancer_id = azurerm_lb.load-balancer.id
  name            = "BackEndAddressPool"
}
resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.rg-group.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.load-balancer.id
  protocol                       = "Tcp"
  frontend_port_start            = 50010
  frontend_port_end              = 50015
  backend_port                   = 22
  frontend_ip_configuration_name = "LoadBalancerIPAddress"
}
resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.load-balancer.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80

}

resource "azurerm_lb_rule" "load-rule" {
  loadbalancer_id                = azurerm_lb.load-balancer.id
  name                           = "LBrule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerIPAddress"
  probe_id                       = azurerm_lb_probe.probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]

}