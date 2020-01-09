resource "github_repository" "mock-nifi" {
  name        = "mock-nifi"
  description = "Mock nifi endpoint - writes posted data to disk."

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "mock-nifi-dataworks" {
  repository = "${github_repository.mock-nifi.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "mock-nifi-master" {
  branch         = "${github_repository.mock-nifi.default_branch}"
  repository     = "${github_repository.mock-nifi.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
