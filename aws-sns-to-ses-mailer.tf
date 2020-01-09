resource "github_repository" "aws-sns-to-ses-mailer" {
  name        = "aws-sns-to-ses-mailer"
  description = "AWS Lambda application to send emails via AWS SES using information recieved from AWS SNS notification"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "aws-sns-to-ses-mailer-dataworks" {
  repository = "${github_repository.aws-sns-to-ses-mailer.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "aws-sns-to-ses-mailer-master" {
  branch         = "${github_repository.aws-sns-to-ses-mailer.default_branch}"
  repository     = "${github_repository.aws-sns-to-ses-mailer.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
