locals {
  pipeline_name = "pdm-dataset-generation"
}

resource "github_repository" "aws-pdm-dataset-generation" {
  name        = "aws-pdm-dataset-generation"
  description = "Infra for Physical Data Model generation"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-pdm-dataset-generation_dataworks" {
  repository = github_repository.aws-pdm-dataset-generation.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws-pdm-dataset-generation_master" {
  branch         = github_repository.aws-pdm-dataset-generation.default_branch
  repository     = github_repository.aws-pdm-dataset-generation.name
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws-pdm-dataset-generation" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws-pdm-dataset-generation.name
}

resource "github_repository_webhook" "aws-pdm-dataset-generation" {
  repository = github_repository.aws-pdm-dataset-generation.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.pipeline_name}/resources/${github_repository.aws-pdm-dataset-generation.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws-pdm-dataset-generation_pr" {
  repository = github_repository.aws-pdm-dataset-generation.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.pipeline_name}/resources/${github_repository.aws-pdm-dataset-generation.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

