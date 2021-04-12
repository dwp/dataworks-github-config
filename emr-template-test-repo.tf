locals {
  emr_template_test_repo_pipeline_name = "emr_template_test_repo"
}

resource "github_repository" "emr_template_test_repo" {
  name             = "emr-template-test-repo"
  description      = "emr_template_test_repo"
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
    repository = "aws-emr-template-repository"
  }
}

resource "github_team_repository" "emr_template_test_repo_dataworks" {
  repository = github_repository.emr_template_test_repo.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "emr_template_test_repo_master" {
  branch         = github_repository.emr_template_test_repo.default_branch
  repository     = github_repository.emr_template_test_repo.name
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

resource "github_issue_label" "emr_template_test_repo" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.emr_template_test_repo.name
}

resource "null_resource" "emr_template_test_repo" {
  triggers = {
    repo = github_repository.emr_template_test_repo.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.emr_template_test_repo.name} '${github_repository.emr_template_test_repo.description}' ${github_repository.emr_template_test_repo.template.0.repository}"
  }
}

resource "github_repository_webhook" "emr_template_test_repo" {
  repository = github_repository.emr_template_test_repo.name
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.emr_template_test_repo_pipeline_name}/resources/${github_repository.emr_template_test_repo.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "emr_template_test_repo_pr" {
  repository = github_repository.emr_template_test_repo.name
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${local.emr_template_test_repo_pipeline_name}/resources/${github_repository.emr_template_test_repo.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
