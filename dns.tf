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

# Locals block for DNS management.
locals {
  private_domains = { for k, v in azurerm_dns_a_record.internal : k => "${v.name}.${var.dns_managed_zone}" }
  public_domains  = { for k, v in azurerm_dns_a_record.external : k => "${v.name}.${var.dns_managed_zone}" }
  all_domains     = concat(values(local.private_domains), values(local.public_domains))
}

# A list of DNS records for external (aka public) purpose.
resource "azurerm_dns_a_record" "external" {
  for_each = var.dns_records_public

  name                = each.value
  zone_name           = var.dns_managed_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.public.ip_address]

  tags = var.tags
}

# A list of DNS records for internal (aka private) purpose.
resource "azurerm_dns_a_record" "internal" {
  for_each = var.dns_records_private

  name                = each.value
  zone_name           = var.dns_managed_zone
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_public_ip.private.ip_address]

  tags = var.tags
}
