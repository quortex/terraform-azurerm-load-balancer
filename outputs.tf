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

output "dns_records_public" {
  value       = local.public_domains
  description = "A map with dns records in given dns zone for each dns_records_public provided in variables."
}

output "dns_records_private" {
  value       = local.private_domains
  description = "A map with dns records in given dns zone for each dns_records_private provided in variables."
}

output "app_gateway_public_ip" {
  value       = azurerm_public_ip.public.ip_address
  description = "The public application gateway ip address."
}

output "app_gateway_private_ip" {
  value       = azurerm_public_ip.private.ip_address
  description = "The private application gateway ip address."
}

output "ssl_certificate_common_name" {
  value       = try(acme_certificate.certificate.0.common_name, "")
  description = "The certificate's common name, the primary domain that the certificate will be recognized for."
}

output "ssl_certificate_pem" {
  value       = try(acme_certificate.certificate.0.certificate_pem, "")
  description = "The certificate in PEM format. This does not include the issuer_pem. This certificate can be concatenated with issuer_pem to form a full chain."
  sensitive   = true
}

output "ssl_issuer_pem" {
  value       = try(acme_certificate.certificate.0.issuer_pem, "")
  description = "The intermediate certificates of the issuer. Multiple certificates are concatenated in this field when there is more than one intermediate certificate in the chain."
  sensitive   = true
}