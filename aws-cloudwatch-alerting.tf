resource "github_repository" "aws-cloudwatch-alerting" {
  name        = "aws-cloudwatch-alerting"
  description = "Lambda function to send CloudWatch alerts to Slack"

  allow_merge_commit = false
  auto_init          = true
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-cloudwatch-alerting-dataworks" {
  repository = "${github_repository.aws-cloudwatch-alerting.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "aws-cloudwatch-alerting-master" {
  branch         = "${github_repository.aws-cloudwatch-alerting.default_branch}"
  repository     = "${github_repository.aws-cloudwatch-alerting.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
