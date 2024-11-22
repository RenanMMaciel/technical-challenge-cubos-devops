resource "docker_container" "database" {
  name  = "database"
  hostname = "database"
  image = "postgres:15.8"

  env = [
    "POSTGRES_USER=${var.POSTGRES_USER}",
    "POSTGRES_PASSWORD=${var.POSTGRES_PASSWORD}",
    "POSTGRES_DB=${var.POSTGRES_DB}",
    "DATABASE_ADMIN_PASSWORD=${var.DATABASE_ADMIN_PASSWORD}"
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    host_path      = "${abspath(path.module)}/../database/script.sh"
    container_path = "/docker-entrypoint-initdb.d/script.sh"
  }

  volumes {
    volume_name    = docker_volume.database_data.name
    container_path = "/var/lib/postgresql/data"
  }

  volumes {
    volume_name    = docker_volume.database_logs.name
    container_path = "/var/log/postgresql"
  }

  networks_advanced {
    name = docker_network.internal_network.name
  }

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  restart = "always"
}

resource "docker_container" "backend" {
  name  = "backend"
  hostname = "backend"
  image = docker_image.backend.name

  depends_on = [docker_container.database]

  ports {
    internal = 8080
    external = 8080
  }

  networks_advanced {
    name = docker_network.internal_network.name
  }

  networks_advanced {
    name = docker_network.external_network.name
  }

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  restart = "always"
}

resource "docker_container" "frontend" {
  name  = "frontend"
  hostname = "frontend"
  image = docker_image.frontend.name

  depends_on = [docker_container.backend]

  ports {
    internal = 80
    external = 80
  }

  networks_advanced {
    name = docker_network.external_network.name
  }

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  restart = "always"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"

  depends_on = [docker_container.frontend]

  ports {
    internal = 9090
    external = 9090
  }

  volumes {
    host_path      = "${abspath(path.module)}/../monitoring/prometheus/prometheus.yml"
    container_path = "/etc/prometheus/prometheus.yml"
  }

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  restart = "always"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"

  depends_on = [docker_container.prometheus]

  ports {
    internal = 3000
    external = 3000
  }

  volumes {
    host_path      = "${abspath(path.module)}/../monitoring/grafana/prometheus-datasource.yml"
    container_path = "/etc/grafana/provisioning/datasources/prometheus-datasource.yml"
  }

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  restart = "always"
}

resource "docker_container" "postgres_exporter" {
  name  = "postgres_exporter"
  image = "quay.io/prometheuscommunity/postgres-exporter:latest"

  env = [
    "DATA_SOURCE_NAME=postgresql://${var.POSTGRES_USER}:${var.POSTGRES_PASSWORD}@database:5432/${var.POSTGRES_DB}?sslmode=disable"
  ]

  ports {
    internal = 9187
    external = 9187
  }

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  depends_on = [docker_container.prometheus]

  restart = "always"
}
