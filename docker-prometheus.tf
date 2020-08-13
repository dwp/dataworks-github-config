resource "github_repository" "docker_prometheus" {
  name             = "docker-prometheus"
  description      = "Repo for the DataWorks Prometheus Docker image"
  auto_init        = true
  license_template = "isc"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "docker_prometheus_dataworks" {
  repository = github_repository.docker_prometheus.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_prometheus_master" {
  branch         = github_repository.docker_prometheus.default_branch
  repository     = github_repository.docker_prometheus.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker_prometheus_dockerhub_password" {
  repository      = github_repository.docker_prometheus.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = local.dockerhub_password
}

resource "github_actions_secret" "docker_prometheus_dockerhub_username" {
  repository      = github_repository.docker_prometheus.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = local.dockerhub_username
}

resource "github_actions_secret" "docker_prometheus_snyk_token" {
  repository      = github_repository.docker_prometheus.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = local.snyk_token
}

