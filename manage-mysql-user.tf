resource "github_repository" "manage-mysql-user" {
  name        = "manage-mysql-user"
  description = "Manages MySQL users"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "manage-mysql-user-dataworks" {
  repository = github_repository.manage-mysql-user.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "manage-mysql-user-master" {
  branch         = github_repository.manage-mysql-user.default_branch
  repository     = github_repository.manage-mysql-user.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "manage-mysql-user_github_email" {
  repository      = github_repository.manage-mysql-user.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = local.github_email
}

resource "github_actions_secret" "manage-mysql-user_github_username" {
  repository      = github_repository.manage-mysql-user.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = local.github_username
}

resource "github_actions_secret" "manage-mysql-user_github_token" {
  repository      = github_repository.manage-mysql-user.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = local.github_token
}

