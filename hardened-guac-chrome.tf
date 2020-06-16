resource "github_repository" "hardened-guac-chrome" {
  name        = "hardened-guac-chrome"
  description = "The hardened Guacamole Chrome container"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  auto_init              = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "github_team_repository" "hardened-guac-chrome-dataworks" {
  repository = "${github_repository.hardened-guac-chrome.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "hardened-guac-chrome-master" {
  branch         = "${github_repository.hardened-guac-chrome.default_branch}"
  repository     = "${github_repository.hardened-guac-chrome.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
