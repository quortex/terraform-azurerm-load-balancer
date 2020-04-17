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

# A subnet for public application gateway usage.
resource "azurerm_subnet" "app_gateway_public" {
  name                 = var.public_app_gateway_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network
  address_prefix       = var.public_app_gateway_address_prefix
}

# The public application gateway public IP.
resource "azurerm_public_ip" "public" {
  name                = var.public_app_gateway_frontend_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

# The public application gateway.
resource "azurerm_application_gateway" "public" {
  count               = length(var.public_app_gateway_backend_ip_addresses) > 0 ? 1 : 0
  name                = var.public_app_gateway_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Application gateway SKU.
  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
  }

  # Application gateway autoscale configuration
  autoscale_configuration {
    min_capacity = var.public_app_gateway_min_capacity
    max_capacity = var.public_app_gateway_max_capacity
  }

  # Application gateway IP configuration.
  gateway_ip_configuration {
    name      = var.public_app_gateway_ip_config_name
    subnet_id = azurerm_subnet.app_gateway_public.id
  }

  # Application gateway frontend IP configuration.
  frontend_ip_configuration {
    name                 = var.public_app_gateway_frontend_ip_config_name
    public_ip_address_id = azurerm_public_ip.public.id
  }

  # A frontend port for HTTP traffic.
  frontend_port {
    name = var.public_app_gateway_frontend_port_name_http
    port = 80
  }

  # A frontend port for HTTPS traffic.
  dynamic "frontend_port" {
    for_each = var.ssl_enabled ? [null] : []

    content {
      name = var.public_app_gateway_frontend_port_name_https
      port = 443
    }
  }

  # HTTP listeners
  dynamic "http_listener" {
    for_each = var.dns_records_public

    content {
      name                           = "${var.public_app_gateway_http_listener_name_prefix}-${http_listener.key}"
      host_name                      = "${http_listener.value}.${var.dns_managed_zone}"
      frontend_ip_configuration_name = var.public_app_gateway_frontend_ip_config_name
      frontend_port_name             = var.public_app_gateway_frontend_port_name_http
      protocol                       = "Http"
    }
  }

  # HTTPS listeners
  dynamic "http_listener" {
    for_each = var.ssl_enabled ? var.dns_records_public : {}

    content {
      name                           = "${var.public_app_gateway_https_listener_name_prefix}-${http_listener.key}"
      host_name                      = "${http_listener.value}.${var.dns_managed_zone}"
      frontend_ip_configuration_name = var.public_app_gateway_frontend_ip_config_name
      frontend_port_name             = var.public_app_gateway_frontend_port_name_https
      protocol                       = "Https"
      ssl_certificate_name           = var.public_app_gateway_ssl_certificate_name
    }
  }

  # Routing rules for HTTP listeners.
  dynamic "request_routing_rule" {
    for_each = var.dns_records_public

    content {
      name                       = "${var.public_app_gateway_request_routing_rule_http_name_prefix}-${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${var.public_app_gateway_http_listener_name_prefix}-${request_routing_rule.key}"
      backend_address_pool_name  = var.public_app_gateway_backend_address_pool_name
      backend_http_settings_name = var.public_app_gateway_http_setting_name
    }
  }

  # Routing rules for HTTPS listeners.
  dynamic "request_routing_rule" {
    for_each = var.ssl_enabled ? var.dns_records_public : {}

    content {
      name                       = "${var.public_app_gateway_request_routing_rule_https_name_prefix}-${request_routing_rule.key}"
      rule_type                  = "Basic"
      http_listener_name         = "${var.public_app_gateway_https_listener_name_prefix}-${request_routing_rule.key}"
      backend_address_pool_name  = var.public_app_gateway_backend_address_pool_name
      backend_http_settings_name = var.public_app_gateway_http_setting_name
    }
  }

  # Public App Gateway SSL certificate management.
  dynamic "ssl_certificate" {
    for_each = var.ssl_enabled ? [null] : []

    content {
      name     = var.public_app_gateway_ssl_certificate_name
      data     = acme_certificate.certificate[0].certificate_p12
      password = random_password.password[0].result
    }
  }

  # Backend address pool pointing to public ingress controller.
  backend_address_pool {
    name         = var.public_app_gateway_backend_address_pool_name
    ip_addresses = var.public_app_gateway_backend_ip_addresses
  }

  # Backend http settings as HTTP.
  # SSL termination is done at app gateway level.
  backend_http_settings {
    name                  = var.public_app_gateway_http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 10
    probe_name            = var.public_app_gateway_hc_probe_name
  }

  # Public application gateway Health check.
  probe {
    name                = var.public_app_gateway_hc_probe_name
    host                = "127.0.0.1"
    interval            = 5
    protocol            = "Http"
    path                = "/ping/"
    timeout             = 2
    unhealthy_threshold = 2
  }

  tags = var.tags

  depends_on = [
    azurerm_public_ip.public
  ]
}
