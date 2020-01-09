resource "github_repository" "terraform-aws-vpc" {
  name        = "terraform-aws-vpc"
  description = "A Terraform module to create an AWS VPC with consistent features"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-vpc-dataworks" {
  repository = "${github_repository.terraform-aws-vpc.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-vpc-master" {
  branch         = "${github_repository.terraform-aws-vpc.default_branch}"
  repository     = "${github_repository.terraform-aws-vpc.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
