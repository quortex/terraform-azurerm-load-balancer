[![Quortex][logo]](https://quortex.io)
# terraform-azurerm-load-balancer
A terraform module for Quortex infrastructure Azure load balancing layer.

It provides a set of resources necessary to provision the Quortex infrastructure load balancers, DNS and ssl certificates on Microsoft Azure.

This module is available on [Terraform Registry][registry_tf_azurerm_load_balancer].

Get all our terraform modules on [Terraform Registry][registry_tf_modules] or on [Github][github_tf_modules] !

## Created resources

This module creates the following resources on Azure:

- an Application Gateway for public traffic (live)
- an Application Gateway for internal traffic (administration)
- a list of DNS records

It also give the possibility to create some SSL certificates with Let's Encrypt.

## Usage example

```hcl
module "load-balancer" {
  source = "quortex/load-balancer/azurerm"

  # Globally used variables.
  subscription_id     = local.subscription_id
  tenant_id           = local.tenant_id
  location            = local.resource_group_location
  resource_group_name = local.resource_group_name
  virtual_network     = module.network.virtual_network_name
  name                = "quortex"

  # Load balancers backend configuration.
  public_app_gateway_backend_ip_addresses  = var.external_lb_ip
  private_app_gateway_backend_ip_addresses = var.internal_lb_ip

  # DNS configuration.
  dns_managed_zone = "quortex.mydomain.com"
  dns_records_public = {
    live = "live"
  }
  dns_records_private = {
    api = "api"
  }

  # A list of IP ranges to whitelist for private load balancer access.
  private_app_gateway_whitelisted_ips = []
}
```

---

## Related Projects

This project is part of our terraform modules to provision a Quortex infrastructure for Microsoft Azure.

![infra_azure]

Check out these related projects.

- [terraform-azurerm-network][registry_tf_azurerm_network] - A terraform module for Quortex infrastructure network layer.

- [terraform-azurerm-aks-cluster][registry_tf_azurerm_aks_cluster] - A terraform module for Quortex infrastructure AKS cluster layer.

- [terraform-azurerm-storage][registry_tf_azurerm_storage] - A terraform module for Quortex infrastructure Azure persistent storage layer.

## Help

**Got a question?**

File a GitHub [issue](https://github.com/quortex/terraform-azurerm-load-balancer/issues) or send us an [email][email].


  [logo]: https://storage.googleapis.com/quortex-assets/logo.webp
  [email]: mailto:info@quortex.io
  [infra_azure]: https://storage.googleapis.com/quortex-assets/infra_azure_001.jpg
  [registry_tf_modules]: https://registry.terraform.io/modules/quortex
  [registry_tf_azurerm_network]: https://registry.terraform.io/modules/quortex/network/azurerm
  [registry_tf_azurerm_aks_cluster]: https://registry.terraform.io/modules/quortex/aks-cluster/azurerm
  [registry_tf_azurerm_load_balancer]: https://registry.terraform.io/modules/quortex/load-balancer/azurerm
  [registry_tf_azurerm_storage]: https://registry.terraform.io/modules/quortex/storage/azurerm
  [github_tf_modules]: https://github.com/quortex?q=terraform-
