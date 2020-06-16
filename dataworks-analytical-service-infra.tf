resource "github_repository" "dataworks-analytical-service-infra" {
  name        = "dataworks-analytical-service-infra"
  description = "Terraform for analytical services infrastructure"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-analytical-service-infra_dataworks" {
  repository = "${github_repository.dataworks-analytical-service-infra.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks-analytical-service-infra_master" {
  branch         = "${github_repository.dataworks-analytical-service-infra.default_branch}"
  repository     = "${github_repository.dataworks-analytical-service-infra.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/dataworks-analytical-service-infra-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
