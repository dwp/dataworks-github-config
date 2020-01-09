resource "github_repository" "dataworks-github-config" {
  name        = "dataworks-github-config"
  description = "Manage GitHub team and repository configuration for DataWorks"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-github-config-dataworks" {
  repository = "${github_repository.dataworks-github-config.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks-github-config-master" {
  branch         = "${github_repository.dataworks-github-config.default_branch}"
  repository     = "${github_repository.dataworks-github-config.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
