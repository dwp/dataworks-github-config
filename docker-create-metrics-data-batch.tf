resource "github_repository" "docker-create-metrics-data-batch" {
  name        = "docker-create-metrics-data-batch"
  description = "A container with required extensions and libraries for creating test data for Analytical Environment Performance Monitor"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = false

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "docker-create-metrics-data-batch-dataworks" {
  repository = github_repository.docker-create-metrics-data-batch.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-create-metrics-data-batch-master" {
  branch         = github_repository.docker-create-metrics-data-batch.default_branch
  repository     = github_repository.docker-create-metrics-data-batch.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker-create-metrics-data-batch_github_email" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = local.github_email
}

resource "github_actions_secret" "docker-create-metrics-data-batch_github_username" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = local.github_username
}

resource "github_actions_secret" "docker-create-metrics-data-batch_github_token" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = local.github_token
}

resource "github_actions_secret" "docker-create-metrics-data-batch-dockerhub-password" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = local.dockerhub_password
}

resource "github_actions_secret" "docker-create-metrics-data-batch-dockerhub-username" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = local.dockerhub_username
}

resource "github_actions_secret" "docker-create-metrics-data-batch-snyk-token" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = local.snyk_token
}

resource "github_actions_secret" "docker-create-metrics-data-batch-slack-webhook" {
  repository      = github_repository.docker-create-metrics-data-batch.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = local.slack_webhook_url
}

