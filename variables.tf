variable "project_id" {
  description = "diplom-470819"
  type        = string
}

variable "region" {
  description = "Основной регион GCP"
  type        = string
  default     = "europe-west4"
}

variable "prod_zones" {
  description = "Зоны для PROD (europe-west4)"
  type        = list(string)
  default = [
    "europe-west4-a",
    "europe-west4-b"
  ]
}

variable "dev_zones" {
  description = "Зоны для DEV (europe-west3)"
  type        = list(string)
  default = [
    "europe-west3-a",
    "europe-west3-b"
  ]
}
variable "ssh_private_key_path" {
  description = "Path to the private SSH key"
  type        = string
  default     = "~/.ssh/id_rsa"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
