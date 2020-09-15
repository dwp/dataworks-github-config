resource "github_repository" "dataworks-analytical-custom-auth-flow" {
  name        = "dataworks-analytical-custom-auth-flow"
  description = "Three lambdas to create a custom authentication flow in cognito for the analytical environment"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-analytical-custom-auth-flow-dataworks" {
  repository = github_repository.dataworks-analytical-custom-auth-flow.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-analytical-custom-auth-flow-master" {
  branch         = github_repository.dataworks-analytical-custom-auth-flow.default_branch
  repository     = github_repository.dataworks-analytical-custom-auth-flow.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "dataworks-analytical-custom-auth-flow-snyk-token" {
  repository      = github_repository.dataworks-analytical-custom-auth-flow.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

