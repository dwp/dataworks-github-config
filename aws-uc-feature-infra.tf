locals {
  aws_uc_feature_pipeline_name = "uc-feature-infrastructure"
}

resource "github_repository" "aws_uc_feature" {
  name        = "aws-uc-feature-infrastructure"
  description = "The EMR infrastructure for aws-uc-feature."
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "aws-emr-template-repository"
  }
}

resource "github_team_repository" "aws_uc_feature_dataworks" {
  repository = github_repository.aws_uc_feature.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_uc_feature_master" {
  branch         = github_repository.aws_uc_feature.default_branch
  repository     = github_repository.aws_uc_feature.name
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

resource "github_issue_label" "aws_uc_feature" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws_uc_feature.name
}

resource "null_resource" "aws_uc_feature" {
  triggers = {
    repo = github_repository.aws_uc_feature.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_uc_feature.name} '${github_repository.aws_uc_feature.description}' ${github_repository.aws_uc_feature.template.0.repository}"
  }
}

resource "github_repository_webhook" "aws_uc_feature" {
  repository = github_repository.aws_uc_feature.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.aws_uc_feature_pipeline_name}/resources/${github_repository.aws_uc_feature.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws_uc_feature_pr" {
  repository = github_repository.aws_uc_feature.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.aws_uc_feature_pipeline_name}/resources/${github_repository.aws_uc_feature.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
