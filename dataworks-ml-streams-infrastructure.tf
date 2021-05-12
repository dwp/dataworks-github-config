locals {
  pipeline_name = "dataworks-ml-streams-broker"
}

resource "github_repository" "dataworks-ml-streams-broker" {
  name             = "dataworks-ml-streams-broker"
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

resource "github_team_repository" "dataworks-ml-streams-broker" {
  repository = github_repository.dataworks-ml-streams-broker.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-ml-streams-broker-master" {
  branch         = github_repository.dataworks-ml-streams-broker.default_branch
  repository     = github_repository.dataworks-ml-streams-broker.name
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

resource "github_issue_label" "dataworks-ml-streams-broker" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks-ml-streams-broker.name
}

resource "null_resource" "dataworks-ml-streams-broker" {
  triggers = {
    repo = github_repository.dataworks-ml-streams-broker.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks-ml-streams-broker.name} '${github_repository.dataworks-ml-streams-broker.description}' ${github_repository.dataworks-ml-streams-broker.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks-ml-streams-broker" {
  repository = github_repository.dataworks-ml-streams-broker.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.pipeline_name}/resources/${github_repository.dataworks-ml-streams-broker.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks-ml-streams-broker_pr" {
  repository = github_repository.dataworks-ml-streams-broker.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.pipeline_name}/resources/${github_repository.dataworks-ml-streams-broker.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
