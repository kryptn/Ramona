variable "do_token" {
  type = string
}

variable "github_username" {
  type = string
}

variable "github_personal_access_token" {
  type = string
}

variable "slack_token" {
  type = string
}

variable "container_version" {
  type    = string
  default = "latest"
}

variable "public_key_file" {
  type = string
  default = ""
}

variable "private_key_file" {
  type = string
  default = ""
}

variable "public_key" {
  type    = string
  default = ""
}

variable "private_key" {
  type    = string
  default = ""
}