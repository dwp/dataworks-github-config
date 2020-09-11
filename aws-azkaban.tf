resource "github_repository" "aws_azkaban" {
  name             = "aws-azkaban"
  description      = "An AWS based azkaban platform"
  auto_init        = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = var.github_organization
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "aws_azkaban_dataworks" {
  repository = github_repository.aws_azkaban.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_azkaban_master" {
  branch         = github_repository.aws_azkaban.default_branch
  repository     = github_repository.aws_azkaban.name
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

resource "null_resource" "aws_azkaban" {
  triggers = {
    repo = github_repository.aws_azkaban.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_azkaban.name} '${github_repository.aws_azkaban.description}' ${github_repository.aws_azkaban.template.0.repository}"
  }
}

resource "github_repository_webhook" "aws_azkaban" {
  repository = github_repository.aws_azkaban.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.aws_azkaban.name}/resources/${github_repository.aws_azkaban.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws_azkaban_pr" {
  repository = github_repository.aws_azkaban.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.aws_azkaban.name}/resources/${github_repository.aws_azkaban.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
