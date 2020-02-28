terraform {
  required_version = "~> 0.12.0"
}

resource "null_resource" "docker_run" {
  provisioner "remote-exec" {
    inline = [
      "docker login -u ${var.github_username} -p ${var.github_personal_access_token} docker.pkg.github.com",
      "docker pull docker.pkg.github.com/kryptn/ramona/ramona:${var.container_version}",
      "docker run -dit --name ramona_notifier --restart always -e SLACK_TOKEN=${var.slack_token} -e RAMONA_CONFIG_URL=${var.ramona_config_url} docker.pkg.github.com/kryptn/ramona/ramona:${var.container_version}"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.private_key
      host        = var.host_ipv4_address
    }
  }

  provisioner "remote-exec" {
    when = destroy

    inline = [
      "docker stop ramona_notifier || echo 'already stopped or does not exist'",
      "docker rm ramona_notifier || echo 'already removed or does not exist'",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = var.private_key
      host        = var.host_ipv4_address
    }
  }
}


