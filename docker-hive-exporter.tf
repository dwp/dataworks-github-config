resource "github_repository" "hive_exporter" {
  name        = "hive-exporter"
  description = "Prometheus exporter for hive metrics"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "hive_exporter_dataworks" {
  repository = github_repository.hive_exporter.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "hive_exporter_master" {
  branch         = github_repository.hive_exporter.default_branch
  repository     = github_repository.hive_exporter.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "hive_exporter_dockerhub_password" {
  repository      = github_repository.hive_exporter.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "hive_exporter_dockerhub_username" {
  repository      = github_repository.hive_exporter.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "hive_exporter_snyk_token" {
  repository      = github_repository.hive_exporter.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

