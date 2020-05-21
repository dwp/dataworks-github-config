resource "github_repository" "custom-auth-lambda-triggers" {
  name        = "custom-auth-lambda-triggers"
  description = "Three lambdas to create a custom authentication flow in cognito for the analytical environment"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "example_dataworks" {
  repository = "${github_repository.custom-auth-lambda-triggers.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "example_master" {
  branch         = "${github_repository.custom-auth-lambda-triggers.default_branch}"
  repository     = "${github_repository.custom-auth-lambda-triggers.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos.
    contexts = ["concourse-ci/custom-auth-lambda-triggers-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
