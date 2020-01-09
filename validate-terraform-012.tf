resource "github_repository" "validate-terraform-012" {
  name        = "validate-terraform-012"
  description = "Simple job to run Terraform 0.12 checklist against all Terraform repos"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "validate-terraform-012" {
  repository = "${github_repository.validate-terraform-012.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "validate-terraform-012" {
  branch         = "${github_repository.validate-terraform-012.default_branch}"
  repository     = "${github_repository.validate-terraform-012.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
