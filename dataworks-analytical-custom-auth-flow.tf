resource "github_repository" "dataworks-analytical-custom-auth-flow" {
  name        = "dataworks-analytical-custom-auth-flow"
  description = "Three lambdas to create a custom authentication flow in cognito for the analytical environment"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "example_dataworks" {
  repository = "${github_repository.dataworks-analytical-custom-auth-flow.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "example_master" {
  branch         = "${github_repository.dataworks-analytical-custom-auth-flow.default_branch}"
  repository     = "${github_repository.dataworks-analytical-custom-auth-flow.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos
    contexts = ["concourse-ci/dataworks-analytical-custom-auth-flow-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
