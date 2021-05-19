resource "github_repository" "dataworks-github-config" {
  name        = "dataworks-github-config"
  description = "Manage GitHub team and repository configuration for DataWorks"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-github-config-dataworks" {
  repository = github_repository.dataworks-github-config.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-github-config-master" {
  branch         = github_repository.dataworks-github-config.default_branch
  repository     = github_repository.dataworks-github-config.name
  enforce_admins = true

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks-github-config" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks-github-config.name
}

resource "github_repository_webhook" "dataworks-github-config" {
  repository = github_repository.dataworks-github-config.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/github-config/resources/${github_repository.dataworks-github-config.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks-github-config-pr" {
  repository = github_repository.dataworks-github-config.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/github-config/resources/${github_repository.dataworks-github-config.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

