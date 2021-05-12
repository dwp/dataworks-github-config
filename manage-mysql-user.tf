resource "github_repository" "manage-mysql-user" {
  name        = "manage-mysql-user"
  description = "Manages MySQL users"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

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
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "manage-mysql-user" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.manage-mysql-user.name
}

resource "github_actions_secret" "manage-mysql-user_github_email" {
  repository      = github_repository.manage-mysql-user.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "manage-mysql-user_github_username" {
  repository      = github_repository.manage-mysql-user.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "manage-mysql-user_github_token" {
  repository      = github_repository.manage-mysql-user.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

