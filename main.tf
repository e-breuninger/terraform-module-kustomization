/**
 * # Terraform Module Kustomization
 *
 * This module is a convenience wrapper for the kustomization_resource.
 * (https://registry.terraform.io/providers/kbst/kustomization/latest/docs)
 * It creates kustomization resources from a kustomization data source.
 */

terraform {
  required_providers {
    kustomization = {
      source  = "kbst/kustomization"
      version = "~> 0.9"
    }
  }
  required_version = "~> 1.0"
}

variable "kustomization_data_source" {
  type = object({
    ids       = set(string)
    ids_prio  = list(set(string))
    manifests = map(string)
  })
  description = "This input accepts a kustomization_build or kustomization_overlay data source as input."
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = var.kustomization_data_source.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(var.kustomization_data_source.manifests[each.value])
    : var.kustomization_data_source.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "p1" {
  for_each = var.kustomization_data_source.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(var.kustomization_data_source.manifests[each.value])
    : var.kustomization_data_source.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }

  depends_on = [kustomization_resource.p0]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "p2" {
  for_each = var.kustomization_data_source.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(var.kustomization_data_source.manifests[each.value])
    : var.kustomization_data_source.manifests[each.value]
  )

  depends_on = [kustomization_resource.p1]
}
