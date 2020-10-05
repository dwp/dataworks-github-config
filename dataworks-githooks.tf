resource "github_repository" "dataworks_githooks" {
  name        = "dataworks-githooks"
  description = "Repo for holding DataWorks Git hooks"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_githooks_dataworks" {
  repository = github_repository.dataworks_githooks.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks_githooks_master" {
  branch         = github_repository.dataworks_githooks.default_branch
  repository     = github_repository.dataworks_githooks.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks_githooks" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks_githooks.name
}

