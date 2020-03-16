resource "github_repository" "aws-analytical-env" {
  name        = "aws-analytical-env"
  description = "Infrastucure for the AWS Analytical Environment"

  allow_merge_commit = false
  has_issues         = true
  auto_init          = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-analytical-dataworks" {
  repository = "${github_repository.aws-analytical-env.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-analytical-env-master" {
  branch         = "${github_repository.aws-analytical-env.default_branch}"
  repository     = "${github_repository.aws-analytical-env.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
