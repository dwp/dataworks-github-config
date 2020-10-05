resource "github_repository" "github-repo-config-examples" {
  name        = "github-repo-config-examples"
  description = "Examples and templates for configuring GitHub repositories using Terraform"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "github-repo-config-examples-dataworks" {
  repository = github_repository.github-repo-config-examples.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "github-repo-config-examples-master" {
  branch         = github_repository.github-repo-config-examples.default_branch
  repository     = github_repository.github-repo-config-examples.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "github-repo-config-examples" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.github-repo-config-examples.name
}

