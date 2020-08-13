resource "github_repository" "aws_internet_egress" {
  name        = "aws-internet-egress"
  description = "DataWorks AWS Internet Egress"
  auto_init   = true

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

resource "github_team_repository" "aws_internet_egress_dataworks" {
  repository = github_repository.aws_internet_egress.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws_internet_egress_master" {
  branch         = github_repository.aws_internet_egress.default_branch
  repository     = github_repository.aws_internet_egress.name
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

resource "null_resource" "aws_internet_egress" {
  triggers = {
    repo = github_repository.aws_internet_egress.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws_internet_egress.name} '${github_repository.aws_internet_egress.description}' ${github_repository.aws_internet_egress.template[0].repository}"
  }
}

resource "github_repository_webhook" "aws_internet_egress" {
  repository = github_repository.aws_internet_egress.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/internet_egress/resources/${github_repository.aws_internet_egress.name}/check/webhook?webhook_token=${local.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws_internet_egress_pr" {
  repository = github_repository.aws_internet_egress.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/internet_egress/resources/${github_repository.aws_internet_egress.name}-pr/check/webhook?webhook_token=${local.github_webhook_token}"
    content_type = "form"
  }
}

