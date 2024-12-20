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

variable "timeout" {
  type        = string
  default     = "5m"
  description = "Timeout for create, update and delete"
}

locals {
  p1_sensitive_ids = toset([
    for id in var.kustomization_data_source.ids_prio[1] : id
    if contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", id)["group_kind"])
  ])
  p1_nonsensitive_ids = setsubtract(var.kustomization_data_source.ids_prio[1], local.p1_sensitive_ids)
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "p0" {
  for_each = var.kustomization_data_source.ids_prio[0]

  manifest = var.kustomization_data_source.manifests[each.value]
  timeouts {
    create = var.timeout
    update = var.timeout
    delete = var.timeout
  }
}

resource "kustomization_resource" "p1_sensitive" {
  for_each = local.p1_sensitive_ids

  manifest = sensitive(var.kustomization_data_source.manifests[each.value])

  wait = true

  timeouts {
    create = var.timeout
    update = var.timeout
    delete = var.timeout
  }

  depends_on = [kustomization_resource.p0]
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait for any deployment or daemonset to become ready
resource "kustomization_resource" "p1" {
  for_each = local.p1_nonsensitive_ids

  manifest = var.kustomization_data_source.manifests[each.value]

  wait = true
  timeouts {
    create = var.timeout
    update = var.timeout
    delete = var.timeout
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
  timeouts {
    create = var.timeout
    update = var.timeout
    delete = var.timeout
  }

  depends_on = [kustomization_resource.p1]
}

output "p0" {
  value       = kustomization_resource.p0
  description = "Kustomization resources applied with priority 0"
}

output "p1_sensitive" {
  value       = kustomization_resource.p1_sensitive
  description = "Sensitive kustomization resources applied with priority 1"
}

output "p1" {
  value       = kustomization_resource.p1
  description = "Kustomization resources applied with priority 1"
}

output "p2" {
  value       = kustomization_resource.p2
  description = "Kustomization resources applied with priority 2"
}
