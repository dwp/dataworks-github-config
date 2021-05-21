locals {
  dataworks_metrics_infrastructure_pipeline_name = "metrics-infrastructure"
}

resource "github_repository" "dataworks_metrics_infrastructure" {
  name        = "dataworks-metrics-infrastructure"
  description = "Repo for storing the Metrics Infrastructure to be used in AWS"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_metrics_infrastructure_dataworks" {
  repository = github_repository.dataworks_metrics_infrastructure.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_metrics_infrastructure_master" {
  branch         = github_repository.dataworks_metrics_infrastructure.default_branch
  repository     = github_repository.dataworks_metrics_infrastructure.name
  enforce_admins = true

  required_status_checks {
    strict = true

    # The contexts line should only be kept for Terraform repos.
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_metrics_infrastructure" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_metrics_infrastructure.name
}

resource "github_repository_webhook" "dataworks_metrics_infrastructure" {
  repository = github_repository.dataworks_metrics_infrastructure.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_metrics_infrastructure_pipeline_name}/resources/${github_repository.dataworks_metrics_infrastructure.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_metrics_infrastructure_pr" {
  repository = github_repository.dataworks_metrics_infrastructure.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_metrics_infrastructure_pipeline_name}/resources/${github_repository.dataworks_metrics_infrastructure.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_actions_secret" "terraform_12_version" {
  repository      = github_repository.dataworks_metrics_infrastructure.name
  secret_name     = "TERRAFORM_12_VERSION"
  plaintext_value = var.terraform_12_version
}

resource "github_actions_secret" "terraform_13_version" {
  repository      = github_repository.dataworks_metrics_infrastructure.name
  secret_name     = "TERRAFORM_13_VERSION"
  plaintext_value = var.terraform_13_version
}
