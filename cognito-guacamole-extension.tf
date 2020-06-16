resource "github_repository" "cognito-guacamole-extension" {
  name        = "cognito-guacamole-extension"
  description = "Integration between cognito and Apache Guacamole"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "cognito-guacamole-extension-dataworks" {
  repository = "${github_repository.cognito-guacamole-extension.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "cognito-guacamole-extension-master" {
  branch         = "${github_repository.cognito-guacamole-extension.default_branch}"
  repository     = "${github_repository.cognito-guacamole-extension.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
