<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.54.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [digitalocean_droplet.blue](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_droplet.green](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/droplet) | resource |
| [digitalocean_floating_ip.app_ip](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/floating_ip) | resource |
| [digitalocean_floating_ip_assignment.assign](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/floating_ip_assignment) | resource |
| [external_external.active_droplet](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_droplet_id"></a> [active\_droplet\_id](#input\_active\_droplet\_id) | n/a | `number` | `null` | no |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | DigitalOcean API token | `string` | n/a | yes |
| <a name="input_ssh_key_id"></a> [ssh\_key\_id](#input\_ssh\_key\_id) | SSH key ID to access the droplet | `string` | n/a | yes |
| <a name="input_use_var_for_droplet_id"></a> [use\_var\_for\_droplet\_id](#input\_use\_var\_for\_droplet\_id) | Use active\_droplet\_id instead of data.external | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blue_id"></a> [blue\_id](#output\_blue\_id) | n/a |
| <a name="output_blue_ip"></a> [blue\_ip](#output\_blue\_ip) | n/a |
| <a name="output_floating_ip"></a> [floating\_ip](#output\_floating\_ip) | n/a |
| <a name="output_green_id"></a> [green\_id](#output\_green\_id) | n/a |
| <a name="output_green_ip"></a> [green\_ip](#output\_green\_ip) | n/a |
<!-- END_TF_DOCS -->