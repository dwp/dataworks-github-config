locals {
  aws_emr_template_pipeline_name = "aws_emr_template"
}

resource "github_repository" "aws_emr_template" {
  name             = "aws-emr-template"
  description      = "A template repository for building EMR cluster in AWS"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws_emr_template_dataworks" {
  repository = github_repository.aws_emr_template.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_emr_template_master" {
  branch         = github_repository.aws_emr_template.default_branch
  repository     = github_repository.aws_emr_template.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws_emr_template" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws_emr_template.name
}

resource "null_resource" "aws_emr_template" {
  triggers = {
    repo = github_repository.aws_emr_template.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_emr_template.name} '${github_repository.aws_emr_template.description}' ${github_repository.aws_emr_template.template.0.repository}"
  }
}

resource "github_repository_webhook" "aws_emr_template" {
  repository = github_repository.aws_emr_template.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.aws_emr_template_pipeline_name}/resources/${github_repository.aws_emr_template.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws_emr_template_pr" {
  repository = github_repository.aws_emr_template.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.aws_emr_template_pipeline_name}/resources/${github_repository.aws_emr_template.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
