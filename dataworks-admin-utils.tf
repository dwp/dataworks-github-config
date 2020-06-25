resource "github_repository" "dataworks-admin-utils" {
  name        = "dataworks-admin-utils"
  description = "Contains DataWorks administrative utilities"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_admin_utils_dataworks" {
  repository = "${github_repository.dataworks-admin-utils.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_admin_utils_master" {
  branch         = "${github_repository.dataworks-admin-utils.default_branch}"
  repository     = "${github_repository.dataworks-admin-utils.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "dataworks-admin-utils_github_email" {
  repository      = "${github_repository.dataworks-admin-utils.name}"
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = "${var.github_email}"
}

resource "github_actions_secret" "dataworks-admin-utils_github_username" {
  repository      = "${github_repository.dataworks-admin-utils.name}"
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = "${var.github_username}"
}

resource "github_actions_secret" "dataworks-admin-utils_github_token" {
  repository      = "${github_repository.dataworks-admin-utils.name}"
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = "${var.github_token}"
}
