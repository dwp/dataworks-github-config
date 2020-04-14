resource "github_repository" "eks-cluster" {
  name        = "eks-cluster"
  description = "Github repo for automating the creation of eks-cluster(s) via eksctl"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "eks-cluster_dataworks" {
  repository = "${github_repository.eks-cluster.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "eks-cluster_master" {
  branch         = "${github_repository.eks-cluster.default_branch}"
  repository     = "${github_repository.eks-cluster.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos.
    contexts = ["concourse-ci/eks-cluster-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
