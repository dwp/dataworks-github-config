resource "github_repository" "dataworks_development_tools" {
  name        = "dataworks-development-tools"
  description = "Infrastructure for development tools"
  auto_init   = true

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

resource "github_team_repository" "dataworks_development_tools_dataworks" {
  repository = github_repository.dataworks_development_tools.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_development_tools_master" {
  branch         = github_repository.dataworks_development_tools.default_branch
  repository     = github_repository.dataworks_development_tools.name
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

resource "github_issue_label" "dataworks_development_tools" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_development_tools.name
}

resource "null_resource" "dataworks_development_tools" {
  triggers = {
    repo = github_repository.dataworks_development_tools.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.dataworks_development_tools.name} '${github_repository.dataworks_development_tools.description}' ${github_repository.dataworks_development_tools.template[0].repository}"
  }
}

resource "github_repository_webhook" "dataworks_development_tools" {
  repository = github_repository.dataworks_development_tools.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/development_tools/resources/${github_repository.dataworks_development_tools.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "dataworks_development_tools_pr" {
  repository = github_repository.dataworks_development_tools.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/development_tools/resources/${github_repository.dataworks_development_tools.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_actions_secret" "dataworks_development_tools_github_email" {
  repository      = github_repository.dataworks_development_tools.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "dataworks_development_tools_github_username" {
  repository      = github_repository.dataworks_development_tools.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "dataworks_development_tools_github_token" {
  repository      = github_repository.dataworks_development_tools.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

resource "github_actions_secret" "dataworks_development_tools_terraform_version" {
  repository      = github_repository.dataworks_development_tools.name
  secret_name     = "TERRAFORM_VERSION"
  plaintext_value = var.terraform_12_version
}

resource "github_actions_secret" "dataworks_development_tools_terraform_13_version" {
  repository      = github_repository.dataworks_development_tools.name
  secret_name     = "TERRAFORM_13_VERSION"
  plaintext_value = var.terraform_13_version
}
