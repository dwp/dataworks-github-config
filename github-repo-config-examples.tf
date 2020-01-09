resource "github_repository" "github-repo-config-examples" {
  name        = "github-repo-config-examples"
  description = "Examples and templates for configuring GitHub repositories using Terraform"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "github-repo-config-examples-dataworks" {
  repository = "${github_repository.github-repo-config-examples.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "github-repo-config-examples-master" {
  branch         = "${github_repository.github-repo-config-examples.default_branch}"
  repository     = "${github_repository.github-repo-config-examples.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
