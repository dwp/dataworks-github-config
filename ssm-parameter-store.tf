resource "github_repository" "ssm-parameter-store" {
  name        = "ssm-parameter-store"
  description = "Private data stored in SSM's parameter store"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ssm-parameter-store-dataworks" {
  repository = github_repository.ssm-parameter-store.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "ssm-parameter-store-master" {
  branch         = github_repository.ssm-parameter-store.default_branch
  repository     = github_repository.ssm-parameter-store.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

