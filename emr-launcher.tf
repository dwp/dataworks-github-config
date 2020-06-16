resource "github_repository" "emr-launcher" {
  name        = "emr-launcher"
  description = "Lambda based EMR Cluster Launcher"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-launcher_dataworks" {
  repository = "${github_repository.emr-launcher.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "emr-launcher_master" {
  branch         = "${github_repository.emr-launcher.default_branch}"
  repository     = "${github_repository.emr-launcher.name}"
  enforce_admins = false

  required_status_checks {
    strict = true

    # The contexts line should only be kept for Terraform repos.
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
