resource "github_repository" "aws-analytical-dataset-generation" {
  name        = "aws-analytical-dataset-generation"
  description = "This repo holds stuff for handling ingested UCFS data "
  auto_init   = true

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

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
