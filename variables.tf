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


variable "subscription_id" {
  type        = string
  description = "The Subscription ID which should be used."
}

variable "tenant_id" {
  type        = string
  description = "The Tenant ID which should be used for ACME DNS challenge."
}

variable "location" {
  type        = string
  description = "The location where the resources should be created."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create resources."
}

variable "dns_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the resource group in which to create A records, if different."
}

variable "name" {
  type        = string
  description = "A name from which the name of the resources will be chosen. Note that each resource name can be set individually."
}

variable "service_principal_id" {
  type        = string
  description = "The Client ID of the Service Principal used for ACME DNS challenge."
}

variable "service_principal_secret" {
  type        = string
  description = "The Client secret of the Service Principal used for ACME DNS challenge."
}

variable "virtual_network" {
  type        = string
  description = "The name of a previously created virtual network in which to create application gateways subnets."
}

variable "public_app_gateway_subnet_name" {
  type        = string
  description = "The name of the public application gateway dedicated subnet."
  default     = ""
}

variable "public_app_gateway_address_prefix" {
  type        = string
  description = "The public application gateway subnet address space CIDR."
  default     = "15.1.0.0/16"
}

variable "public_app_gateway_name" {
  type        = string
  description = "The name of the public application gateway."
  default     = ""
}

variable "public_app_gateway_min_capacity" {
  type        = number
  description = "The public application gateway minimum capacity for autoscaling. Accepted values are in the range 0 to 100."
  default     = 1
}

variable "public_app_gateway_max_capacity" {
  type        = number
  description = "The public application gateway maximum capacity for autoscaling. Accepted values are in the range 2 to 125."
  default     = 20
}

variable "public_app_gateway_frontend_ip_name" {
  type        = string
  description = "The name of the public application gateway frontend IP address."
  default     = ""
}

variable "public_app_gateway_ip_config_name" {
  type        = string
  description = "The name of the public application gateway frontend IP configuration."
  default     = "quortex-public-ip-config"
}

variable "public_app_gateway_frontend_ip_config_name" {
  type        = string
  description = "The name of the public application gateway frontend IP configuration."
  default     = "quortex-public-feip"
}

variable "public_app_gateway_frontend_port_name_http" {
  type        = string
  description = "The name of the public application gateway frontend IP configuration."
  default     = "quortex-public-feport-http"
}

variable "public_app_gateway_frontend_port_name_https" {
  type        = string
  description = "The name of the public application gateway frontend IP configuration."
  default     = "quortex-public-feport-https"
}

variable "public_app_gateway_http_listener_name_prefix" {
  type        = string
  description = "A prefix for public application gateway http listeners. Each name will be computed from this prefix and dns_records_public keys."
  default     = "quortex-public-lstn-http"
}

variable "public_app_gateway_https_listener_name_prefix" {
  type        = string
  description = "A prefix for public application gateway https listeners. Each name will be computed from this prefix and dns_records_public keys."
  default     = "quortex-public-lstn-https"
}

variable "public_app_gateway_request_routing_rule_http_name_prefix" {
  type        = string
  description = "A prefix for public application gateway http request routing rules. Each name will be computed from this prefix and dns_records_public keys."
  default     = "quortex-public-rqrt-http"
}

variable "public_app_gateway_request_routing_rule_https_name_prefix" {
  type        = string
  description = "A prefix for public application gateway https request routing rules. Each name will be computed from this prefix and dns_records_public keys."
  default     = "quortex-public-rqrt-https"
}

variable "public_app_gateway_backend_host_name" {
  type        = string
  description = "Host header to be sent to the public application gateway backend servers."
  default     = null
}

variable "public_app_gateway_backend_address_pool_name" {
  type        = string
  description = "The name of the public application gateway backend address pool."
  default     = "quortex-public-beap"
}

variable "public_app_gateway_http_setting_name" {
  type        = string
  description = "The name of the public application gateway backend HTTP settings collection."
  default     = "quortex-public-be-http"
}

variable "public_app_gateway_hc_probe_name" {
  type        = string
  description = "The name of the public application gateway healtch check probe."
  default     = "quortex-public-probe"
}

variable "public_app_gateway_hc_probe_port" {
  type        = number
  description = "Custom port which will be used for probing the public backend. The valid value ranges from 1 to 65535. In case not set, port from HTTP settings will be used."
  default     = null
}

variable "public_app_gateway_backend_ip_addresses" {
  type        = list(string)
  description = "A list of IP Addresses which should be part of the public application gateway backend address pool."
  default     = []
}

variable "public_app_gateway_ssl_certificate_name" {
  type        = string
  description = "The name of the public application gateway ssl certificate."
  default     = "quortex-public"
}

variable "private_app_gateway_subnet_name" {
  type        = string
  description = "The name of the private application gateway dedicated subnet."
  default     = ""
}

variable "private_app_gateway_address_prefix" {
  type        = string
  description = "The private application gateway subnet address space CIDR."
  default     = "15.2.0.0/16"
}

variable "private_app_gateway_name" {
  type        = string
  description = "The name of the private application gateway."
  default     = ""
}

variable "private_app_gateway_min_capacity" {
  type        = number
  description = "The private application gateway minimum capacity for autoscaling. Accepted values are in the range 0 to 100."
  default     = 0
}

variable "private_app_gateway_max_capacity" {
  type        = number
  description = "The private application gateway maximum capacity for autoscaling. Accepted values are in the range 2 to 125."
  default     = 20
}

variable "private_app_gateway_frontend_ip_name" {
  type        = string
  description = "The name of the private application gateway frontend IP address."
  default     = ""
}

variable "private_app_gateway_ip_config_name" {
  type        = string
  description = "The name of the private application gateway frontend IP configuration."
  default     = "quortex-private-ip-config"
}

variable "private_app_gateway_frontend_ip_config_name" {
  type        = string
  description = "The name of the private application gateway frontend IP configuration."
  default     = "quortex-private-feip"
}

variable "private_app_gateway_frontend_port_name_http" {
  type        = string
  description = "The name of the private application gateway frontend IP configuration."
  default     = "quortex-private-feport-http"
}

variable "private_app_gateway_frontend_port_name_https" {
  type        = string
  description = "The name of the private application gateway frontend IP configuration."
  default     = "quortex-private-feport-https"
}

variable "private_app_gateway_http_listener_name_prefix" {
  type        = string
  description = "A prefix for private application gateway http listeners. Each name will be computed from this prefix and dns_records_private keys."
  default     = "quortex-private-lstn-http"
}

variable "private_app_gateway_https_listener_name_prefix" {
  type        = string
  description = "A prefix for private application gateway https listeners. Each name will be computed from this prefix and dns_records_private keys."
  default     = "quortex-private-lstn-https"
}

variable "private_app_gateway_request_routing_rule_http_name_prefix" {
  type        = string
  description = "A prefix for private application gateway http request routing rules. Each name will be computed from this prefix and dns_records_private keys."
  default     = "quortex-private-rqrt-http"
}

variable "private_app_gateway_request_routing_rule_https_name_prefix" {
  type        = string
  description = "A prefix for private application gateway https request routing rules. Each name will be computed from this prefix and dns_records_private keys."
  default     = "quortex-private-rqrt-https"
}

variable "private_app_gateway_backend_host_name" {
  type        = string
  description = "Host header to be sent to the private application gateway backend servers."
  default     = null
}

variable "private_app_gateway_backend_address_pool_name" {
  type        = string
  description = "The name of the private application gateway backend address pool."
  default     = "quortex-private-beap"
}

variable "private_app_gateway_http_setting_name" {
  type        = string
  description = "The name of the private application gateway backend HTTP settings collection."
  default     = "quortex-private-be-http"
}

variable "private_app_gateway_hc_probe_name" {
  type        = string
  description = "The name of the private application gateway healtch check probe."
  default     = "quortex-private-probe"
}

variable "private_app_gateway_hc_probe_port" {
  type        = number
  description = "Custom port which will be used for probing the private backend. The valid value ranges from 1 to 65535. In case not set, port from HTTP settings will be used."
  default     = null
}

variable "private_app_gateway_backend_ip_addresses" {
  type        = list(string)
  description = "A list of IP Addresses which should be part of the private application gateway backend address pool."
  default     = []
}

variable "private_app_gateway_ssl_certificate_name" {
  type        = string
  description = "The name of the private application gateway ssl certificate."
  default     = "quortex-private"
}

variable "private_app_gateway_security_group_name" {
  type        = string
  description = "The name of the private application gateway security group."
  default     = ""
}

variable "private_app_gateway_whitelisted_ips" {
  type        = list(string)
  description = "A list of IP ranges to whitelist for private application gateway access."
  default     = []
}

variable "dns_managed_zone" {
  type        = string
  description = "The name of an available DNS zone in which to create DNS records."
}

variable "dns_records_private" {
  type        = map(string)
  description = "A map with dns records to add in dns_managed_zone for private endpoints set as value. Full domain names will be exported in a map for the given key."
  default     = {}
}

variable "additional_dns_records_private" {
  type        = list(string)
  description = "A list with additional dns records to add for private endpoints."
  default     = []
}

variable "dns_records_public" {
  type        = map(string)
  description = "A map with dns records to add in dns_managed_zone for public endpoints set as value. Full domain names will be exported in a map for the given key."
  default     = {}
}

variable "additional_dns_records_public" {
  type        = list(string)
  description = "A list with additional dns records to add for public endpoints."
  default     = []
}

variable "ssl_enabled" {
  type        = bool
  description = "Wether to request SSL certificates for application gateways configuration."
  default     = false
}

variable "ssl_certificate_common_name" {
  type        = string
  description = "The SSL certificate common name. Required if ssl_enabled and ssl_certificate_p12 not provided."
  default     = ""
}

variable "ssl_acme_registration_email_address" {
  type        = string
  description = "The ACME registration email address. Required if ssl_enabled and ssl_certificate_p12 not provided."
  default     = ""
}

variable "ssl_certificate_p12" {
  type        = string
  description = "The SSL certificate PKCS12 format, base64 encoded, if you don't want the module to create it. You must also provide its password if any."
  default     = ""
}

variable "ssl_certificate_password" {
  type        = string
  description = "The SSL certificate password."
  default     = ""
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources. A list of key->value pairs."
  default     = {}
}
