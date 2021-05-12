resource "github_repository" "aws-analytical-env" {
  name        = "aws-analytical-env"
  description = "Infrastucure for the AWS Analytical Environment"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)
  auto_init              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-analytical-dataworks" {
  repository = github_repository.aws-analytical-env.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws-analytical-env-master" {
  branch         = github_repository.aws-analytical-env.default_branch
  repository     = github_repository.aws-analytical-env.name
  enforce_admins = true

  required_status_checks {
    contexts = ["concourse-ci/status"]
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws-analytical-env" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws-analytical-env.name
}

resource "github_repository_webhook" "aws-analytical-env" {
  repository = github_repository.aws-analytical-env.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/analytical-env/resources/${github_repository.aws-analytical-env.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws-analytical-env_pr" {
  repository = github_repository.aws-analytical-env.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/analytical-env/resources/${github_repository.aws-analytical-env.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws-rbac" {
  repository = github_repository.aws-analytical-env.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/aws-rbac/resources/${github_repository.aws-analytical-env.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

