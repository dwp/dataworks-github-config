resource "github_repository" "aws-analytical-dataset-generation" {
  name        = "aws-analytical-dataset-generation"
  description = "This repo holds stuff for handling ingested UCFS data "
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-analytical-dataset-generation_dataworks" {
  repository = "${github_repository.aws-analytical-dataset-generation.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-analytical-dataset-generation_master" {
  branch         = "${github_repository.aws-analytical-dataset-generation.default_branch}"
  repository     = "${github_repository.aws-analytical-dataset-generation.name}"
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

resource "github_repository_webhook" "aws_analytical_dataset_generation" {
  repository = "${github_repository.aws-analytical-dataset-generation.name}"
  events     = ["push"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.aws-analytical-dataset-generation.name}/resources/${github_repository.aws-analytical-dataset-generation.name}/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}

resource "github_repository_webhook" "aws_analytical_dataset_generation_pr" {
  repository = "${github_repository.aws-analytical-dataset-generation.name}"
  events     = ["pull_request"]

  configuration {
    url          = "https://${var.aws_concourse_domain_name}/api/v1/teams/${var.aws_concourse_team}/pipelines/${github_repository.aws-analytical-dataset-generation.name}/resources/${github_repository.aws-analytical-dataset-generation.name}-pr/check/webhook?webhook_token=${var.github_webhook_token}"
    content_type = "form"
  }
}
