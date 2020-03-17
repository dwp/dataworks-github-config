resource "github_repository" "aws-secrets-manager" {
  name        = "aws-secrets-manager"
  description = "Repo containg infrastructure for AWS Secrets Mangager"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-secrets-manager_dataworks" {
  repository = "${github_repository.aws-secrets-manager.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-secrets-manager_master" {
  branch         = "${github_repository.aws-secrets-manager.default_branch}"
  repository     = "${github_repository.aws-secrets-manager.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/aws-secrets-manager-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
