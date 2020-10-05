resource "github_repository" "cloudwatch-event-dispatcher" {
  name        = "cloudwatch-event-dispatcher"
  description = "Lambda to receive CloudWatch events and post to SNS with additional message attributes"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "cloudwatch-event-dispatcher-dataworks" {
  repository = github_repository.cloudwatch-event-dispatcher.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "cloudwatch-event-dispatcher-master" {
  branch         = github_repository.cloudwatch-event-dispatcher.default_branch
  repository     = github_repository.cloudwatch-event-dispatcher.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "cloudwatch-event-dispatcher" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.cloudwatch-event-dispatcher.name
}

resource "github_actions_secret" "cloudwatch-event-dispatcher_github_email" {
  repository      = github_repository.cloudwatch-event-dispatcher.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "cloudwatch-event-dispatcher_github_username" {
  repository      = github_repository.cloudwatch-event-dispatcher.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "cloudwatch-event-dispatcher_github_token" {
  repository      = github_repository.cloudwatch-event-dispatcher.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

