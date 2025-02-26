# Terraform Module Kustomization

This module is a convenience wrapper for the kustomization\_resource.
(https://registry.terraform.io/providers/kbst/kustomization/latest/docs)
It creates kustomization resources from a kustomization data source.

## Migration for v3

We moved Roles to prio 0 to prevent the creation of Rolebindings before their Roles exist.
The cluster might reject those orphan Rolebindings because of potential privilege escalation.

To prevent recreation of those kinds, add moved blocks like below.

```terraform
moved {
  from = module.kustomization.kustomization_resource.p1["rbac.authorization.k8s.io/Role/<Namespace>/<RoleName>"]
  to   = module.kustomization.kustomization_resource.p0["rbac.authorization.k8s.io/Role/<Namespace>/<RoleName>"]
}
```

## Migration for v2

Because of changes to sensitive value detection in terraform v1.10, sensitive kinds now have their own resource.
To prevent recreation of those kinds, add moved blocks like below.

```terraform
moved {
  from = module.keycloak.module.kustomization.kustomization_resource.p1["_/Secret/<Namespace>/<SecretName>"]
  to   = module.keycloak.module.kustomization.kustomization_resource.p1_sensitive["_/Secret/<Namespace>/<SecretName>"]
}
```

<!-- BEGIN_TF_DOCS -->


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kustomization_data_source"></a> [kustomization\_data\_source](#input\_kustomization\_data\_source) | This input accepts a kustomization\_build or kustomization\_overlay data source as input. | <pre>object({<br/>    ids       = set(string)<br/>    ids_prio  = list(set(string))<br/>    manifests = map(string)<br/>  })</pre> | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Timeout for create, update and delete | `string` | `"5m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_p0"></a> [p0](#output\_p0) | Kustomization resources applied with priority 0 |
| <a name="output_p1"></a> [p1](#output\_p1) | Kustomization resources applied with priority 1 |
| <a name="output_p1_sensitive"></a> [p1\_sensitive](#output\_p1\_sensitive) | Sensitive kustomization resources applied with priority 1 |
| <a name="output_p2"></a> [p2](#output\_p2) | Kustomization resources applied with priority 2 |
<!-- END_TF_DOCS -->
