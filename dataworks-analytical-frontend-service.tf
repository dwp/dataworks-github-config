resource "github_repository" "frontend-service" {
  name        = "dataworks-analytical-frontend-service"
  description = "Frontend service providing user authentication and interface with orchestration service"

  allow_merge_commit = false
  has_issues         = true
  auto_init          = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "frontend-service-dataworks" {
  repository = "${github_repository.frontend-service.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "frontend-service-master" {
  branch         = "${github_repository.frontend-service.default_branch}"
  repository     = "${github_repository.frontend-service.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker-frontend-service-dockerhub-password" {
  repository      = "${github_repository.docker-frontend-service.name}"
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = "${var.dockerhub_password}"
}

resource "github_actions_secret" "docker-frontend-service-dockerhub-username" {
  repository      = "${github_repository.docker-frontend-service.name}"
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = "${var.dockerhub_username}"
}

resource "github_actions_secret" "docker-frontend-service-snyk-token" {
  repository      = "${github_repository.docker-frontend-service.name}"
  secret_name     = "SNYK_TOKEN"
  plaintext_value = "${var.snyk_token}"
}
