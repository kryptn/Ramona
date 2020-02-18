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

variable "google_cloud_keyfile" {
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
    credentials = var.google_cloud_keyfile
    project = var.gcp_project
    region = var.gcp_region
}


resource "google_cloud_run_service" "default" {
    name = "ramona-notifier"
    location = var.gcp_region

    template {
        spec {
            containers {
                image = "docker.pkg.github.com/kryptn/ramona/ramona:${var.container_version}"
                env {
                    name = "SLACK_TOKEN"
                    value = var.slack_token
                }
            }
        }
    }
}