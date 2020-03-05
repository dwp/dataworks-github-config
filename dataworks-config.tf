resource "dataworks-config" "example" {
  name        = "example"
  description = "example"
  auto_init   = true

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "example_dataworks" {
  repository = "${dataworks-config.example.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "example_master" {
  branch         = "${dataworks-config.example.default_branch}"
  repository     = "${dataworks-config.example.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
