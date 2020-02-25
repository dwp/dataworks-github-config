resource "github_repository" "aws-authentication" {
  name        = "aws-authentication"
  description = "AWS Cognito management"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-authentication-dataworks" {
  repository = "${github_repository.aws-authentication.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-authentication-master" {
  branch         = "${github_repository.aws-authentication.default_branch}"
  repository     = "${github_repository.aws-authentication.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
