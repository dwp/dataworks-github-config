resource "github_repository" "terraform-aws-emr-cluster" {
  name        = "terraform-aws-emr-cluster"
  description = "A Terraform module to create an Amazon Web Services (AWS) Elastic MapReduce (EMR) cluster."

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "develop"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "terraform-aws-emr-cluster-dataworks" {
  repository = "${github_repository.terraform-aws-emr-cluster.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "terraform-aws-emr-cluster-master" {
  branch         = "${github_repository.terraform-aws-emr-cluster.default_branch}"
  repository     = "${github_repository.terraform-aws-emr-cluster.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
