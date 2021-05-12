resource "github_repository" "terraform-aws-prowler-monitoring" {
  name        = "terraform-aws-prowler-monitoring"
  description = "A collection of log metric filters and alarms to satisfy Prowler Monitoring checks"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = concat(local.common_topics, local.aws_topics)

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-prowler-monitoring-dataworks" {
  repository = github_repository.terraform-aws-prowler-monitoring.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-prowler-monitoring-master" {
  branch         = github_repository.terraform-aws-prowler-monitoring.default_branch
  repository     = github_repository.terraform-aws-prowler-monitoring.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "terraform-aws-prowler-monitoring" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.terraform-aws-prowler-monitoring.name
}

