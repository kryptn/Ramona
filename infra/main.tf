terraform {
    required_version = "~> 0.12.0"
    backend "remote" {}
}

variable "gcp_project" {
    type = string
}

variable "gcp_region" {
    type = string
}

variable "gcp_zone" {
    type = string
}

variable "gcp_credentials" {
    type = string
}

variable "slack_token" {
    type = string
}

variable "container_version" {
    type = string
    default = "latest"
}

provider "google" {
    credentials = variable.gcp_credentials
    project = variable.gcp_project
    region = variable.gcp_region
}


resource "google_cloud_run_service" "default" {
    name = "ramona-notifier"
    location = variable.region

    template {
        spec {
            containers {
                image = "docker.pkg.github.com/kryptn/ramona/ramona:${variable.container_version}"
            }
            env {
                name = "SLACK_TOKEN"
                value = variable.slack_token
            }
        }
    }
}