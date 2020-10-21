variable "name" {
  description = "Name of the role and policy being created."
  type        = string
  default     = ""
}

variable "principal_arns" {
  description = "ARNs of accounts, groups, or users with the ability to assume this role."
  type        = list(string)
}

variable "zone_id" {
  description = "Zone ID which need to delegate"
  type        = string
}

variable "external_id" {
  description = "To assume the created role, users must be in the trusted account and provide this exact external ID"
  type        = string
  default     = ""
}