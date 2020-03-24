resource "github_repository" "emr-cluster-broker-client" {
  name        = "emr-cluster-broker-client"
  description = "Lambda for sending JSON payloads to the Cluster Broker API"
  auto_init   = true

  allow_merge_commit = false
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-cluster-broker-client_dataworks" {
  repository = "${github_repository.emr-cluster-broker-client.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "emr-cluster-broker-client_master" {
  branch         = "${github_repository.emr-cluster-broker-client.default_branch}"
  repository     = "${github_repository.emr-cluster-broker-client.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
    # The contexts line should only be kept for Terraform repos.
    # contexts = ["concourse-ci/emr-cluster-broker-client-pr"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
