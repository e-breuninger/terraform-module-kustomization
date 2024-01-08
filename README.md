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

| Name | Description |
|------|-------------|
| <a name="output_p0"></a> [p0](#output\_p0) | Kustomization resources applied with priority 0 |
| <a name="output_p1"></a> [p1](#output\_p1) | Kustomization resources applied with priority 1 |
| <a name="output_p2"></a> [p2](#output\_p2) | Kustomization resources applied with priority 2 |
<!-- END_TF_DOCS -->
