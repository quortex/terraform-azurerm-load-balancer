/**
 * Copyright 2020 Quortex
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# A subnet for private application gateway usage.
resource "azurerm_subnet" "app_gateway_private" {
  name                 = length(var.private_app_gateway_subnet_name) > 0 ? var.private_app_gateway_subnet_name : "${var.name}-app-gw-private"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network
  address_prefixes     = [var.private_app_gateway_address_prefix]
}

# The private application gateway public IP.
resource "azurerm_public_ip" "private" {
  name                = length(var.private_app_gateway_frontend_ip_name) > 0 ? var.private_app_gateway_frontend_ip_name : "${var.name}-private"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# The private application gateway.
resource "azurerm_application_gateway" "private" {
  count               = length(var.private_app_gateway_backend_ip_addresses) > 0 ? 1 : 0
  name                = length(var.private_app_gateway_name) > 0 ? var.private_app_gateway_name : "${var.name}-private"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Application gateway SKU.
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  # Application gateway autoscale configuration
  autoscale_configuration {
    min_capacity = var.private_app_gateway_min_capacity
    max_capacity = var.private_app_gateway_max_capacity
  }

  # Application gateway IP configuration.
  gateway_ip_configuration {
    name      = var.private_app_gateway_ip_config_name
    subnet_id = azurerm_subnet.app_gateway_private.id
  }

  # Application gateway frontend IP configuration.
  frontend_ip_configuration {
    name                 = var.private_app_gateway_frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.private.id
  }

  # A frontend port for HTTP traffic.
  frontend_port {
    name = var.private_app_gateway_frontend_port_name_http
    port = 80
  }

  # A frontend port for HTTPS traffic.
  dynamic "frontend_port" {
    for_each = var.ssl_enabled ? [null] : []

    content {
      name = var.private_app_gateway_frontend_port_name_https
      port = 443
    }
  }

  # HTTP listeners
  dynamic "http_listener" {
    for_each = var.dns_records_private

    content {
      name                           = "${var.private_app_gateway_http_listener_name_prefix}-${http_listener.key}"
      host_name                      = "${http_listener.value}.${var.dns_managed_zone}"
      frontend_ip_configuration_name = var.private_app_gateway_frontend_ip_config_name
      frontend_port_name             = var.private_app_gateway_frontend_port_name_http
      protocol                       = "Http"
    }
  }
  dynamic "http_listener" {
    for_each = var.additional_dns_records_private

    content {
      name                           = "${var.private_app_gateway_http_listener_name_prefix}-add${http_listener.key}"
      host_name                      = http_listener.value
      frontend_ip_configuration_name = var.private_app_gateway_frontend_ip_config_name
      frontend_port_name             = var.private_app_gateway_frontend_port_name_http
      protocol                       = "Http"
    }
  }

  # HTTPS listeners
  dynamic "http_listener" {
    for_each = var.ssl_enabled ? var.dns_records_private : {}

    content {
      name                           = "${var.private_app_gateway_https_listener_name_prefix}-${http_listener.key}"
      host_name                      = "${http_listener.value}.${var.dns_managed_zone}"
      frontend_ip_configuration_name = var.private_app_gateway_frontend_ip_config_name
      frontend_port_name             = var.private_app_gateway_frontend_port_name_https
      protocol                       = "Https"
      ssl_certificate_name           = var.ssl_termination ? var.private_app_gateway_ssl_certificate_name : null
    }
  }
  dynamic "http_listener" {
    for_each = var.ssl_enabled ? var.additional_dns_records_private : []

    content {
      name                           = "${var.private_app_gateway_https_listener_name_prefix}-add${http_listener.key}"
      host_name                      = http_listener.value
      frontend_ip_configuration_name = var.private_app_gateway_frontend_ip_config_name
      frontend_port_name             = var.private_app_gateway_frontend_port_name_https
      protocol                       = "Https"
      ssl_certificate_name           = var.ssl_termination ? var.private_app_gateway_ssl_certificate_name : null
    }
  }

  # Routing rules for HTTP listeners.
  dynamic "request_routing_rule" {
    for_each = var.dns_records_private

    content {
      name                       = "${var.private_app_gateway_request_routing_rule_http_name_prefix}-${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${var.private_app_gateway_http_listener_name_prefix}-${request_routing_rule.key}"
      backend_address_pool_name  = var.private_app_gateway_backend_address_pool_name
      backend_http_settings_name = var.private_app_gateway_http_setting_name
    }
  }
  dynamic "request_routing_rule" {
    for_each = var.additional_dns_records_private

    content {
      name                       = "${var.private_app_gateway_request_routing_rule_http_name_prefix}-add${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${var.private_app_gateway_http_listener_name_prefix}-add${request_routing_rule.key}"
      backend_address_pool_name  = var.private_app_gateway_backend_address_pool_name
      backend_http_settings_name = var.private_app_gateway_http_setting_name
    }
  }

  # Routing rules for HTTPS listeners.
  dynamic "request_routing_rule" {
    for_each = var.ssl_enabled ? var.dns_records_private : {}

    content {
      name                       = "${var.private_app_gateway_request_routing_rule_https_name_prefix}-${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${var.private_app_gateway_https_listener_name_prefix}-${request_routing_rule.key}"
      backend_address_pool_name  = var.private_app_gateway_backend_address_pool_name
      backend_http_settings_name = var.private_app_gateway_http_setting_name
    }
  }
  dynamic "request_routing_rule" {
    for_each = var.ssl_enabled ? var.additional_dns_records_private : []

    content {
      name                       = "${var.private_app_gateway_request_routing_rule_https_name_prefix}-add${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${var.private_app_gateway_https_listener_name_prefix}-add${request_routing_rule.key}"
      backend_address_pool_name  = var.private_app_gateway_backend_address_pool_name
      backend_http_settings_name = var.private_app_gateway_http_setting_name
    }
  }

  # Private App Gateway SSL certificate management.
  dynamic "ssl_certificate" {
    for_each = var.ssl_enabled && var.ssl_termination ? [null] : []

    content {
      name     = var.private_app_gateway_ssl_certificate_name
      data     = local.create_ssl_certificate ? acme_certificate.certificate[0].certificate_p12 : var.ssl_certificate_p12
      password = local.create_ssl_certificate ? random_password.password[0].result : var.ssl_certificate_password
    }
  }

  # Backend address pool pointing to private ingress controller.
  backend_address_pool {
    name         = var.private_app_gateway_backend_address_pool_name
    ip_addresses = var.private_app_gateway_backend_ip_addresses
  }

  # Backend http settings as HTTP.
  # SSL termination is done at app gateway level.
  backend_http_settings {
    name                  = var.private_app_gateway_http_setting_name
    host_name             = var.private_app_gateway_backend_host_name
    cookie_based_affinity = "Disabled"
    port                  = var.ssl_enabled && var.ssl_termination ? 443 : 80
    protocol              = var.ssl_enabled && var.ssl_termination ? "Http" : "Https"
    request_timeout       = 10
    probe_name            = var.private_app_gateway_hc_probe_name
  }

  # Private application gateway Health check.
  probe {
    name                = var.private_app_gateway_hc_probe_name
    host                = "127.0.0.1"
    interval            = 5
    protocol            = "Http"
    path                = "/ping/"
    timeout             = 2
    unhealthy_threshold = 2
  }

  tags = var.tags

  depends_on = [
    azurerm_public_ip.private,
  ]
}

# Subnet <-> Network Security Group associations.
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.app_gateway_private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Manages a network security group that contains a list of network security rules asssociated to private AppGateway.
resource "azurerm_network_security_group" "private" {
  name                = length(var.private_app_gateway_security_group_name) > 0 ? var.private_app_gateway_security_group_name : "${var.name}-private-sg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Allow incoming traffic from a source IP or IP range and the destination as either the entire Application Gateway subnet, or to the specific configured private front-end IP. The NSG doesn't work on a public IP.
resource "azurerm_network_security_rule" "allow_whitelisted_ips" {

  # Set this rule only if app_gateway_private_whitelisted_ips not empty.
  count = max(0, min(length(var.private_app_gateway_whitelisted_ips), 1))

  name                        = "AllowWhitelistedIPs"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = var.private_app_gateway_whitelisted_ips
  destination_address_prefix  = var.private_app_gateway_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}

# Allow incoming requests from all sources to ports 65503-65534 for the Application Gateway v1 SKU, and ports 65200-65535 for v2 SKU for back-end health communication.
# This port range is required for Azure infrastructure communication.
# These ports are protected (locked down) by Azure certificates.
# Without appropriate certificates in place, external entities can't initiate changes on those endpoints.
resource "azurerm_network_security_rule" "allow_azure_infra_ports" {
  name                        = "AllowAzureInfraPorts"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "65200-65535"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}

# Allow incoming Azure Load Balancer probes (AzureLoadBalancer tag) on the network security group.
resource "azurerm_network_security_rule" "allow_azure_loadbalancer_probes" {
  name                        = "AllowAzureLoadbalancerProbes"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}

# Allow inbound virtual network traffic (VirtualNetwork tag) on the network security group.
resource "azurerm_network_security_rule" "allow_vnet_inbound" {
  name                        = "AllowVnetInBound"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}

# Block all other incoming traffic by using a deny-all rule.
resource "azurerm_network_security_rule" "deny_all_inbound" {
  name                        = "DenyAllInBound"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.private.name
}
