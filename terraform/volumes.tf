resource "docker_volume" "database_data" {
  name = "database_data"
}

resource "docker_volume" "database_logs" {
  name = "database_logs"
}
