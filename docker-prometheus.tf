resource "github_repository" "docker_prometheus" {
  name             = "docker-prometheus"
  description      = "Repo for the DataWorks Prometheus Docker image"
  auto_init        = true
  license_template = "isc"

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = "${var.github_organization}"
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "docker_prometheus_dataworks" {
  repository = "${github_repository.docker_prometheus.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker_prometheus_master" {
  branch         = "${github_repository.docker_prometheus.default_branch}"
  repository     = "${github_repository.docker_prometheus.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
