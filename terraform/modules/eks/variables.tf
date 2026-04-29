variable "name"               { type = string }
variable "kubernetes_version" { type = string }
variable "vpc_id"             { type = string }
variable "subnet_ids"         { type = list(string) }
variable "node_groups" {
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    labels         = map(string)
  }))
}
variable "cluster_addons" {
  type    = map(any)
  default = {}
}
