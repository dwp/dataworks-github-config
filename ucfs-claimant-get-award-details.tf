resource "github_repository" "ucfs-claimant-get-award-details" {
  name        = "ucfs-claimant-get-award-details"
  description = "Get Award Details Lambda code for UCFS Claimant API endpoint"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ucfs-claimant-get-award-details_dataworks" {
  repository = github_repository.ucfs-claimant-get-award-details.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "ucfs-claimant-get-award-details_master" {
  branch         = github_repository.ucfs-claimant-get-award-details.default_branch
  repository     = github_repository.ucfs-claimant-get-award-details.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "ucfs-claimant-get-award-details" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.ucfs-claimant-get-award-details.name
}

