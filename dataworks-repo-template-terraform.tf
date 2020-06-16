resource "github_repository" "dataworks_repo_template_terraform" {
  name                   = "dataworks-repo-template-terraform"
  description            = "Template Terraform repository for DataWorks GitHub"
  auto_init              = true
  is_template            = true
  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "dataworks_repo_template_terraform_dataworks" {
  repository = "${github_repository.dataworks_repo_template_terraform.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "dataworks_repo_template_terraform_master" {
  branch         = "${github_repository.dataworks_repo_template_terraform.default_branch}"
  repository     = "${github_repository.dataworks_repo_template_terraform.name}"
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
