variable "project_name" {
  type = string
}

variable "bucket_id" {
  type = string
}

variable "bucket_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "extra_origins" {
  type = map(object({
    domain_name = string
    bucket_arn  = string
  }))
  default = {}
}
