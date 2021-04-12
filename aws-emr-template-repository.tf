locals {
  aws_emr_template_repository_pipeline_name = "aws_emr_template_repository"
}

resource "github_repository" "aws_emr_template_repository" {
  name             = "aws-emr-template-repository"
  description      = "A template repository for building EMR cluster in AWS"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  is_template            = true
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "aws_emr_template_repository_dataworks" {
  repository = github_repository.aws_emr_template_repository.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_emr_template_repository_master" {
  branch         = github_repository.aws_emr_template_repository.default_branch
  repository     = github_repository.aws_emr_template_repository.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "aws_emr_template_repository" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.aws_emr_template_repository.name
}

resource "null_resource" "aws_emr_template_repository" {
  triggers = {
    repo = github_repository.aws_emr_template_repository.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_emr_template_repository.name} '${github_repository.aws_emr_template_repository.description}' ${github_repository.aws_emr_template_repository.template.0.repository}"
  }
}

resource "github_repository_webhook" "aws_emr_template_repository" {
  repository = github_repository.aws_emr_template_repository.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.aws_emr_template_repository_pipeline_name}/resources/${github_repository.aws_emr_template_repository.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws_emr_template_repository_pr" {
  repository = github_repository.aws_emr_template_repository.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.aws_emr_template_repository_pipeline_name}/resources/${github_repository.aws_emr_template_repository.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
