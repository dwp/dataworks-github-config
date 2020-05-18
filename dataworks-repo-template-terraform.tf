resource "github_repository" "dataworks-repo-template-terraform" {
  name        = "dataworks-repo-template-terraform"
  description = "Template Terraform repository for DataWorks GitHub"
  auto_init   = true
  is_template = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks-repo-template-terraform_dataworks" {
  repository = "${github_repository.dataworks-repo-template-terraform.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks-repo-template-terraform_master" {
  branch         = "${github_repository.dataworks-repo-template-terraform.default_branch}"
  repository     = "${github_repository.dataworks-repo-template-terraform.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["concourse-ci/status"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
