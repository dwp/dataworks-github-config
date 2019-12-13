resource "github_repository" "emr-cluster-broker" {
  name        = "emr-cluster-broker"
  description = "A lightweight API to passthrough requests to AWS SDK and create EMR clusters"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-cluster-broker-dataworks" {
  repository = "${github_repository.emr-cluster-broker.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "emr-cluster-broker-master" {
  branch         = "${github_repository.emr-cluster-broker.default_branch}"
  repository     = "${github_repository.emr-cluster-broker.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
