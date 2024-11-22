resource "docker_image" "backend" {
  name = "backend:latest"

  build {
    context = "${path.module}/../backend"
  }

  triggers = {
    always_rebuild = "${timestamp()}"
  }
}

resource "docker_image" "frontend" {
  name = "frontend:latest"

  build {
    context = "${path.module}/../frontend"
  }

  triggers = {
    always_rebuild = "${timestamp()}"
  }
}
