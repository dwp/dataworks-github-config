resource "github_repository" "orchestration-service" {
  name        = "orchestration-service"
  description = "The service orchestrator for providing remote access into the analytical environment"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)
  auto_init              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "orchestration-service-dataworks" {
  repository = github_repository.orchestration-service.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "orchestration-service-master" {
  branch         = github_repository.orchestration-service.default_branch
  repository     = github_repository.orchestration-service.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "orchestration-service" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.orchestration-service.name
}

resource "github_repository_webhook" "orchestration-service" {
  repository = github_repository.orchestration-service.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.orchestration-service.name}/resources/${github_repository.orchestration-service.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "orchestration-service_pr" {
  repository = github_repository.orchestration-service.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.orchestration-service.name}/resources/${github_repository.orchestration-service.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_actions_secret" "orchestration-service-dockerhub-password" {
  repository      = github_repository.orchestration-service.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "orchestration-service-dockerhub-username" {
  repository      = github_repository.orchestration-service.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "orchestration-service-snyk-token" {
  repository      = github_repository.orchestration-service.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "orchestration-service-slack-webhook" {
  repository      = github_repository.orchestration-service.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook_url
}

