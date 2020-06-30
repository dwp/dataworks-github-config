resource "github_repository" "aws-dataworks-pdm" {
  name             = "aws-dataworks-pdm"
  description      = "This repo holds the Physical Data Model (PDM) and its tests"
  auto_init        = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template-terraform"
  }
}

resource "github_team_repository" "terraform-aws-dataworks-pdm" {
  repository = "${github_repository.terraform-aws-dataworks-pdm.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-dataworks-pdm-master" {
  branch         = "${github_repository.aws-dataworks-pdm.default_branch}"
  repository     = "${github_repository.aws-dataworks-pdm.name}"
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

resource "null_resource" "aws-dataworks-pdm" {
  triggers = {
    repo = "${github_repository.aws-dataworks-pdm.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.aws-dataworks-pdm.name} '${github_repository.aws-dataworks-pdm.description}' ${github_repository.aws-dataworks-pdm.template.0.repository}"
  }
}

resource "github_repository_webhook" "aws-dataworks-pdm" {
  repository = "${github_repository.aws-dataworks-pdm.name}"
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.aws-dataworks-pdm.name}/resources/${github_repository.aws-dataworks-pdm.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws-dataworks-pdm_pr" {
  repository = "${github_repository.aws-dataworks-pdm.name}"
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.aws-dataworks-pdm.name}/resources/${github_repository.aws-dataworks-pdm.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
