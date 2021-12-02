# Locals block for DNS management.
locals {
  private_domains = { for k, v in azurerm_dns_a_record.internal : k => "${v.name}.${var.dns_managed_zone}" }
  public_domains  = { for k, v in azurerm_dns_a_record.external : k => "${v.name}.${var.dns_managed_zone}" }
  all_domains     = concat(values(local.private_domains), values(local.public_domains))

  create_ssl_certificate = length(var.ssl_certificate_p12) > 0 ? false : true
}
