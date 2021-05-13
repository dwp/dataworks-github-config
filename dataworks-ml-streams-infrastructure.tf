locals {
  dataworks_ml_streams_infrastructure_pipeline_name = "dataworks_ml_streams_infrastructure"
}

resource "github_repository" "dataworks_ml_streams_infrastructure" {
  name             = "dataworks-ml-streams-infrastructure"
  description      = "Dataworks repository for provisioning kafka cluster"
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

resource "github_team_repository" "dataworks_ml_streams_infrastructure" {
  repository = github_repository.dataworks_ml_streams_infrastructure.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_ml_streams_infrastructure_master" {
  branch         = github_repository.dataworks_ml_streams_infrastructure.default_branch
  repository     = github_repository.dataworks_ml_streams_infrastructure.name
  enforce_admins = true

  required_status_checks {
    strict = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_ml_streams_infrastructure" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_ml_streams_infrastructure.name
}

resource "null_resource" "dataworks_ml_streams_infrastructure" {
  triggers = {
    repo = github_repository.dataworks_ml_streams_infrastructure.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_ml_streams_infrastructure.name} '${github_repository.dataworks_ml_streams_infrastructure.description}' ${github_repository.dataworks_ml_streams_infrastructure.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks_ml_streams_infrastructure" {
  repository = github_repository.dataworks_ml_streams_infrastructure.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_ml_streams_infrastructure_pipeline_name}/resources/${github_repository.dataworks_ml_streams_infrastructure.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_ml_streams_infrastructure_pr" {
  repository = github_repository.dataworks_ml_streams_infrastructure.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.dataworks_ml_streams_infrastructure_pipeline_name}/resources/${github_repository.dataworks_ml_streams_infrastructure.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
