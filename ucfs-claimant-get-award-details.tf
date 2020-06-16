resource "github_repository" "ucfs-claimant-get-award-details" {
  name        = "ucfs-claimant-get-award-details"
  description = "Get Award Details Lambda code for UCFS Claimant API endpoint"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "ucfs-claimant-get-award-details_dataworks" {
  repository = "${github_repository.ucfs-claimant-get-award-details.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "ucfs-claimant-get-award-details_master" {
  branch         = "${github_repository.ucfs-claimant-get-award-details.default_branch}"
  repository     = "${github_repository.ucfs-claimant-get-award-details.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
