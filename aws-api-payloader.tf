resource "github_repository" "aws-api-payloader" {
  name        = "aws-api-payloader"
  description = "Lambda based sender of payloads"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-api-payloader_dataworks" {
  repository = "${github_repository.aws-api-payloader.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-api-payloader_master" {
  branch         = "${github_repository.aws-api-payloader.default_branch}"
  repository     = "${github_repository.aws-api-payloader.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
