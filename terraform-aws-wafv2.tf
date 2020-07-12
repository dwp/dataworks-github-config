resource "github_repository" "terraform-aws-wafv2" {
  name        = "terraform-aws-wafv2"
  description = "A Terraform module to create an AWS WAFV2 with consistent features"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-wafv2-dataworks" {
  repository = "${github_repository.terraform-aws-wafv2.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-wafv2-master" {
  branch         = "${github_repository.terraform-aws-wafv2.default_branch}"
  repository     = "${github_repository.terraform-aws-wafv2.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
