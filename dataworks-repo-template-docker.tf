resource "github_repository" "dataworks_repo_template_docker" {
  name        = "dataworks-repo-template-docker"
  description = "Template Docker repository for DataWorks GitHub"
  auto_init   = true
  is_template = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template"
  }
}

resource "github_team_repository" "dataworks_repo_template_docker_dataworks" {
  repository = "${github_repository.dataworks_repo_template_docker.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_repo_template_docker_master" {
  branch         = "${github_repository.dataworks_repo_template_docker.default_branch}"
  repository     = "${github_repository.dataworks_repo_template_docker.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "dataworks_repo_template_docker_dockerhub_password" {
  repository      = "${github_repository.dataworks_repo_template_docker.name}"
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = "${var.dockerhub_password}"
}

resource "github_actions_secret" "dataworks_repo_template_docker_dockerhub_username" {
  repository      = "${github_repository.dataworks_repo_template_docker.name}"
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = "${var.dockerhub_username}"
}

resource "github_actions_secret" "dataworks_repo_template_docker_snyk_token" {
  repository      = "${github_repository.dataworks_repo_template_docker.name}"
  secret_name     = "SNYK_TOKEN"
  plaintext_value = "${var.snyk_token}"
}
