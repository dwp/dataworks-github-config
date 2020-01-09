resource "github_repository" "terraform-aws-prowler-monitoring" {
  name        = "terraform-aws-prowler-monitoring"
  description = "A collection of log metric filters and alarms to satisfy Prowler Monitoring checks"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-prowler-monitoring-dataworks" {
  repository = "${github_repository.terraform-aws-prowler-monitoring.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-prowler-monitoring-master" {
  branch         = "${github_repository.terraform-aws-prowler-monitoring.default_branch}"
  repository     = "${github_repository.terraform-aws-prowler-monitoring.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
