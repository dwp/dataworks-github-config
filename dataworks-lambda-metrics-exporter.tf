resource "github_repository" "dataworks_lambda_metrics_exporter" {
  name        = "dataworks-lambda-metrics-exporter"
  description = "Lambda to pull Cloudwatch metrics"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_lambda_metrics_exporter_dataworks" {
  repository = github_repository.dataworks_lambda_metrics_exporter.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_lambda_metrics_exporter_master" {
  branch         = github_repository.dataworks_lambda_metrics_exporter.default_branch
  repository     = github_repository.dataworks_lambda_metrics_exporter.name
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos.
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_lambda_metrics_exporter" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_lambda_metrics_exporter.name
}

resource "github_actions_secret" "dataworks_lambda_metrics_exporter_github_email" {
  repository      = github_repository.dataworks_lambda_metrics_exporter.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "dataworks_lambda_metrics_exporter_github_username" {
  repository      = github_repository.dataworks_lambda_metrics_exporter.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "dataworks_lambda_metrics_exporter_github_token" {
  repository      = github_repository.dataworks_lambda_metrics_exporter.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

