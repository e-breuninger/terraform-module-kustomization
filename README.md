<!-- BEGIN_TF_DOCS -->
# Terraform Module Kustomization

This module is a convenience wrapper for the kustomization\_resource.
(https://registry.terraform.io/providers/kbst/kustomization/latest/docs)
It creates kustomization resources from a kustomization data source.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kustomization_data_source"></a> [kustomization\_data\_source](#input\_kustomization\_data\_source) | This input accepts a kustomization\_build or kustomization\_overlay data source as input. | <pre>object({<br>    ids       = set(string)<br>    ids_prio  = list(set(string))<br>    manifests = map(string)<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
