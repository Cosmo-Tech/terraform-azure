locals {
  vnet_name   = "${var.customer_name}-${var.project_name}-${var.project_stage}-vnet"
  subnet_name = "${local.vnet_name}-subnet"
  pods_subnet = "${local.vnet_name}-pods"
  svc_subnet  = "${local.vnet_name}-services"
  lb_name     = "${var.project_name}-${var.project_stage}-lb-ip"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = [var.vnet_address_space]
}

# Subnets
resource "azurerm_subnet" "default" {
  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_iprange]
}

resource "azurerm_subnet" "pods" {
  name                 = local.pods_subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.pods_iprange]
}

resource "azurerm_subnet" "services" {
  name                 = local.svc_subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.services_iprange]
}

# NSG & rules (unchanged)
resource "azurerm_network_security_group" "nsg" {
  name                = "${local.vnet_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Inbound: master → nodes (TCP ports)
resource "azurerm_network_security_rule" "allow_master_to_nodes" {
  name                        = "Allow-Master-To-Nodes"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "AzureCloud" # AKS control plane
  destination_port_ranges     = ["443", "10250", "10255", "9376", "9443"]
  source_port_range           = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

# Inbound: internal node-to-node (TCP + ICMP)
resource "azurerm_network_security_rule" "allow_internal" {
  name                        = "Allow-Internal"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = var.subnet_iprange # all cluster subnets
  destination_port_ranges     = ["10250", "443", "10255"]
  source_port_range           = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_icmp" {
  name                        = "Allow-ICMP"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_address_prefix       = var.subnet_iprange
  destination_address_prefix  = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

# Inbound: public HTTP/HTTPS
resource "azurerm_network_security_rule" "allow_http_https" {
  name                        = "Allow-HTTP-HTTPS"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  destination_port_ranges     = ["80", "443"]
  source_port_range           = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

# Outbound: allow all (egress)
resource "azurerm_network_security_rule" "allow_egress" {
  name                        = "Allow-Egress"
  priority                    = 400
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

# Associate NSG to all subnets
resource "azurerm_subnet_network_security_group_association" "default_nsg_assoc" {
  subnet_id                 = azurerm_subnet.default.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "pods_nsg_assoc" {
  subnet_id                 = azurerm_subnet.pods.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_subnet_network_security_group_association" "svc_nsg_assoc" {
  subnet_id                 = azurerm_subnet.services.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
