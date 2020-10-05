resource "github_repository" "dataworks-open-source-policy" {
  name        = "dataworks-open-source-policy"
  description = "Policy and Guidance from the DWP DataWorks team on working with Open-Source code"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-open-source-policy-dataworks" {
  repository = github_repository.dataworks-open-source-policy.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "dataworks-open-source-policy-master" {
  branch         = github_repository.dataworks-open-source-policy.default_branch
  repository     = github_repository.dataworks-open-source-policy.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "dataworks-open-source-policy" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.dataworks-open-source-policy.name
}

