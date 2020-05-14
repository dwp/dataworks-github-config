resource "github_repository" "aws-pdm-dataset-generation" {
  name        = "aws-pdm-dataset-generation"
  description = "Repo for PDM dataset generation"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-pdm-dataset-generation_dataworks" {
  repository = "${github_repository.aws-pdm-dataset-generation.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-pdm-dataset-generation_master" {
  branch         = "${github_repository.aws-pdm-dataset-generation.default_branch}"
  repository     = "${github_repository.aws-pdm-dataset-generation.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/pdm-dataset-generation-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
