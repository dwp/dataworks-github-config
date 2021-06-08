locals {
  dataworks_aws_data_egress_pipeline_name = "data-egress"
}

resource "github_repository" "dataworks_aws_data_egress" {
  name        = "dataworks-aws-data-egress"
  description = "A repo for Dataworks AWS Data Egress service infrastructure"
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
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "dataworks_aws_data_egress_dataworks" {
  repository = github_repository.dataworks_aws_data_egress.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_aws_data_egress_master" {
  branch         = github_repository.dataworks_aws_data_egress.default_branch
  repository     = github_repository.dataworks_aws_data_egress.name
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

resource "github_issue_label" "dataworks_aws_data_egress" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_aws_data_egress.name
}

resource "null_resource" "dataworks_aws_data_egress" {
  triggers = {
    repo = github_repository.dataworks_aws_data_egress.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_aws_data_egress.name} '${github_repository.dataworks_aws_data_egress.description}' ${github_repository.dataworks_aws_data_egress.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks_aws_data_egress" {
  repository = github_repository.dataworks_aws_data_egress.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_aws_data_egress_pipeline_name}/resources/${github_repository.dataworks_aws_data_egress.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_aws_data_egress_pr" {
  repository = github_repository.dataworks_aws_data_egress.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_aws_data_egress_pipeline_name}/resources/${github_repository.dataworks_aws_data_egress.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
