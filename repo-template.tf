resource "github_repository" "dataworks_repo_template" {
  name        = "dataworks_repo_template"
  description = "dataworks_repo_template"
  auto_init   = true
  is_template = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_repo_template_dataworks" {
  repository = "${github_repository.dataworks_repo_template.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_repo_template_master" {
  branch         = "${github_repository.dataworks_repo_template.default_branch}"
  repository     = "${github_repository.dataworks_repo_template.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
