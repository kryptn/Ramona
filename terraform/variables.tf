variable "host_ipv4_address" {
  type = string
}

variable "private_key" {
  type    = string
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

variable "ramona_config_url" {
  type    = string
  default = "https://gist.githubusercontent.com/kryptn/b3f1090d752b6941d8d8be350e8c7c5e/raw/9a67280125716e50c2ade8efa2a40d93d7365d53/ramona_config.json"
}