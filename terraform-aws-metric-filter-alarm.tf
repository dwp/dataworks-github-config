resource "github_repository" "terraform-aws-metric-filter-alarm" {
  name        = "terraform-aws-metric-filter-alarm"
  description = "Terraform module that creates AWS CloudWatch metric filters and alarms"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-metric-filter-alarm-dataworks" {
  repository = "${github_repository.terraform-aws-metric-filter-alarm.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-metric-filter-alarm-master" {
  branch         = "${github_repository.terraform-aws-metric-filter-alarm.default_branch}"
  repository     = "${github_repository.terraform-aws-metric-filter-alarm.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
