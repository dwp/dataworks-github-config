resource "github_repository" "cloudwatch-event-dispatcher" {
  name        = "cloudwatch-event-dispatcher"
  description = "Lambda to receive CloudWatch events and post to SNS with additional message attributes"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true
}

resource "github_team_repository" "cloudwatch-event-dispatcher-dataworks" {
  repository = "${github_repository.cloudwatch-event-dispatcher.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "cloudwatch-event-dispatcher-master" {
  branch         = "${github_repository.cloudwatch-event-dispatcher.default_branch}"
  repository     = "${github_repository.cloudwatch-event-dispatcher.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
