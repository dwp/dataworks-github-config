resource "github_repository" "tactical-aws-user-creation" {
  name        = "tactical-aws-user-creation"
  description = "Temporary app to create and assign MFA software token code to a user in AWS cognito."
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "tactical-aws-user-creation_dataworks" {
  repository = github_repository.tactical-aws-user-creation.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "tactical-aws-user-creation_master" {
  branch         = github_repository.tactical-aws-user-creation.default_branch
  repository     = github_repository.tactical-aws-user-creation.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "tactical-aws-user-creation" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.tactical-aws-user-creation.name
}

