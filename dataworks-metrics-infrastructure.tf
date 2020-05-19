resource "github_repository" "dataworks_metrics_infrastructure" {
  name        = "dataworks-metrics-infrastructure"
  description = "Repo for storing the Metrics Infrastructure to be used in AWS"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = false
  }
}

resource "github_team_repository" "dataworks_metrics_infrastructure_dataworks" {
  repository = "${github_repository.dataworks_metrics_infrastructure.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_metrics_infrastructure_master" {
  branch         = "${github_repository.dataworks_metrics_infrastructure.default_branch}"
  repository     = "${github_repository.dataworks_metrics_infrastructure.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos.
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
