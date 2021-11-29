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

# Generates a secure private key and encodes it as PEM.
resource "tls_private_key" "private_key" {
  count = var.ssl_enabled ? 1 : 0

  algorithm = "RSA"
}

# The acme_registration resource can be used to create and manage accounts on an ACME server.
# Once registered, the same private key that has been used for registration can be used to request authorizations for certificates.
resource "acme_registration" "reg" {
  count = var.ssl_enabled ? 1 : 0

  account_key_pem = tls_private_key.private_key[0].private_key_pem
  email_address   = var.ssl_acme_registration_email_address
}

# Manage an ACME TLS certificate for all endpoints..
resource "acme_certificate" "certificate" {
  count = var.ssl_enabled ? 1 : 0

  account_key_pem           = acme_registration.reg[0].account_key_pem
  common_name               = var.ssl_certificate_common_name
  subject_alternative_names = local.all_domains
  certificate_p12_password  = random_password.password[0].result

  dns_challenge {
    provider = "azure"
    config = {
      AZURE_CLIENT_ID           = var.service_principal_id
      AZURE_CLIENT_SECRET       = var.service_principal_secret
      AZURE_RESOURCE_GROUP      = length(var.dns_resource_group_name) > 0 ? var.dns_resource_group_name : var.resource_group_name
      AZURE_SUBSCRIPTION_ID     = var.subscription_id
      AZURE_TENANT_ID           = var.tenant_id
      AZURE_PROPAGATION_TIMEOUT = 600
    }
  }
}

resource "random_password" "password" {
  count = var.ssl_enabled ? 1 : 0

  length  = 16
  special = true
}
