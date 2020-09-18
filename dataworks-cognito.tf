resource "github_repository" "dataworks_cognito" {
  name        = "dataworks-cognito"
  description = "Centralised infrastructure for Cognito"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "dataworks_cognito_dataworks" {
  repository = github_repository.dataworks_cognito.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_cognito_master" {
  branch         = github_repository.dataworks_cognito.default_branch
  repository     = github_repository.dataworks_cognito.name
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

resource "null_resource" "dataworks_cognito" {
  triggers = {
    repo = github_repository.dataworks_cognito.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_cognito.name} '${github_repository.dataworks_cognito.description}' ${github_repository.dataworks_cognito.template.0.repository}"
  }
}

resource "github_repository_webhook" "dataworks_cognito" {
  repository = github_repository.dataworks_cognito.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.dataworks_cognito.name}/resources/${github_repository.dataworks_cognito.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_cognito_pr" {
  repository = github_repository.dataworks_cognito.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.dataworks_cognito.name}/resources/${github_repository.dataworks_cognito.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
