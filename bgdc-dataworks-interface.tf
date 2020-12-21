locals {
  bgdc_dataworks_interface_pipeline_name = "bgdc-dataworks-interface"
}

resource "github_repository" "bgdc_dataworks_interface" {
  name             = "bgdc-dataworks-interface"
  description      = "Dataworks interface for Business Glossary & Data Catalog to consume from"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
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

resource "github_team_repository" "bgdc_dataworks_interface_dataworks" {
  repository = github_repository.bgdc_dataworks_interface.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "bgdc_dataworks_interface_master" {
  branch         = github_repository.bgdc_dataworks_interface.default_branch
  repository     = github_repository.bgdc_dataworks_interface.name
  enforce_admins = false

  required_status_checks {
    strict = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "bgdc_dataworks_interface" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.bgdc_dataworks_interface.name
}

resource "null_resource" "bgdc_dataworks_interface" {
  triggers = {
    repo = github_repository.bgdc_dataworks_interface.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.bgdc_dataworks_interface.name} '${github_repository.bgdc_dataworks_interface.description}' ${github_repository.bgdc_dataworks_interface.template.0.repository}"
  }
}

resource "github_repository_webhook" "bgdc_dataworks_interface" {
  repository = github_repository.bgdc_dataworks_interface.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.bgdc_dataworks_interface_pipeline_name}/resources/${github_repository.bgdc_dataworks_interface.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "bgdc_dataworks_interface_pr" {
  repository = github_repository.bgdc_dataworks_interface.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.bgdc_dataworks_interface_pipeline_name}/resources/${github_repository.bgdc_dataworks_interface.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
