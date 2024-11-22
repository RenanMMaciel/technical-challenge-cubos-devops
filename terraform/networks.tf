resource "docker_network" "external_network" {
  name = "external_network"
}

resource "docker_network" "internal_network" {
  name = "internal_network"
}

resource "docker_network" "monitoring_network" {
  name = "monitoring_network"
}
