variable "name"                    { type = string }
variable "engine"                  { type = string }
variable "engine_version"          { type = string }
variable "instance_class"          { type = string }
variable "vpc_id"                  { type = string }
variable "subnet_ids"              { type = list(string) }
variable "allowed_cidr_blocks"     { type = list(string) }
variable "multi_az"                { type = bool; default = false }
variable "deletion_protection"     { type = bool; default = false }
variable "backup_retention_period" { type = number; default = 7 }
