resource "github_repository" "aws-cloudwatch-alerting" {
  name        = "aws-cloudwatch-alerting"
  description = "Lambda function to send CloudWatch alerts to Slack"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-cloudwatch-alerting-dataworks" {
  repository = github_repository.aws-cloudwatch-alerting.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "aws-cloudwatch-alerting-master" {
  branch         = github_repository.aws-cloudwatch-alerting.default_branch
  repository     = github_repository.aws-cloudwatch-alerting.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "aws-cloudwatch-alerting_github_email" {
  repository      = github_repository.aws-cloudwatch-alerting.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = local.github_email
}

resource "github_actions_secret" "aws-cloudwatch-alerting_github_username" {
  repository      = github_repository.aws-cloudwatch-alerting.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = local.github_username
}

resource "github_actions_secret" "aws-cloudwatch-alerting_github_token" {
  repository      = github_repository.aws-cloudwatch-alerting.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = local.github_token
}

