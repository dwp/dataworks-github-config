resource "github_repository" "dataworks-config" {
  name        = "dataworks-config"
  description = "Repo for storing SSM Parameter Store content"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-config_dataworks" {
  repository = github_repository.dataworks-config.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-config_master" {
  branch         = github_repository.dataworks-config.default_branch
  repository     = github_repository.dataworks-config.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

