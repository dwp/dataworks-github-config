resource "github_repository" "docker-headless-chrome" {
  name        = "docker-headless-chrome"
  description = "Dataworks hardened headless Chrome container"

  allow_merge_commit = false
  has_issues         = true
  auto_init          = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-headless-chrome-dataworks" {
  repository = "${github_repository.docker-headless-chrome.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-headless-chrome-master" {
  branch         = "${github_repository.docker-headless-chrome.default_branch}"
  repository     = "${github_repository.docker-headless-chrome.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
