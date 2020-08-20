resource "github_repository" "external_ci_users" {
  name        = "external-ci-users"
  description = "Repo to manage users from a third-party CI/CD tool"
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

resource "github_team_repository" "external_ci_users_dataworks" {
  repository = github_repository.external_ci_users.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "external_ci_users_master" {
  branch         = github_repository.external_ci_users.default_branch
  repository     = github_repository.external_ci_users.name
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

resource "null_resource" "external_ci_users" {
  triggers = {
    repo = github_repository.external_ci_users.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.external_ci_users.name} '${github_repository.external_ci_users.description}' ${github_repository.external_ci_users.template.0.repository}"
  }
}

resource "github_repository_webhook" "external_ci_users" {
  repository = github_repository.external_ci_users.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.external_ci_users.name}/resources/${github_repository.external_ci_users.name}/check/webhook?webhook_token=${local.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "external_ci_users_pr" {
  repository = github_repository.external_ci_users.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.external_ci_users.name}/resources/${github_repository.external_ci_users.name}-pr/check/webhook?webhook_token=${local.github_webhook_token}"
    content_type = "form"
  }
}
