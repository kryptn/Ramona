terraform {
  required_version = "~> 0.12.0"
  # backend "remote" {}
}

provider "digitalocean" {
  token = var.do_token
}

data "null_data_source" "creds" {
  inputs = {
    private_key = var.private_key == "" ? file(var.private_key_file) : var.private_key
    public_key  = var.public_key == "" ? file(var.public_key_file) : var.public_key
  }
}

resource "digitalocean_ssh_key" "default" {
  name       = "quantric-ramona-tf"
  public_key = data.null_data_source.creds.outputs["public_key"]
}

resource "digitalocean_droplet" "ramona" {
  image  = "docker-18-04"
  name   = "ramona-1"
  region = "sfo2"
  size   = "s-1vcpu-1gb"

  ssh_keys = [digitalocean_ssh_key.default.id]

  provisioner "remote-exec" {
    inline = [
      "docker login -u ${var.github_username} -p ${var.github_personal_access_token} docker.pkg.github.com",
      "docker run -dit --restart always -e SLACK_TOKEN=${var.slack_token} docker.pkg.github.com/kryptn/ramona/ramona:latest"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = data.null_data_source.creds.outputs["private_key"]
      host        = self.ipv4_address
    }
  }
}


output "docker_host" {
  value = digitalocean_droplet.ramona.ipv4_address
}

output "ssh_cmd" {
  value = "ssh -i ${var.private_key_file} root@${digitalocean_droplet.ramona.ipv4_address}"
}
