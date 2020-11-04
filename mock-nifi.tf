resource "github_repository" "mock-nifi" {
  name        = "mock-nifi"
  description = "Mock nifi endpoint - writes posted data to disk. Test"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "mock-nifi-dataworks" {
  repository = github_repository.mock-nifi.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "mock-nifi-master" {
  branch         = github_repository.mock-nifi.default_branch
  repository     = github_repository.mock-nifi.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "mock-nifi" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.mock-nifi.name
}

