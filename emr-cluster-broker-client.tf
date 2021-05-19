resource "github_repository" "emr-cluster-broker-client" {
  name        = "emr-cluster-broker-client"
  description = "Lambda for sending JSON payloads to the Cluster Broker API"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-cluster-broker-client_dataworks" {
  repository = github_repository.emr-cluster-broker-client.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "emr-cluster-broker-client_master" {
  branch         = github_repository.emr-cluster-broker-client.default_branch
  repository     = github_repository.emr-cluster-broker-client.name
  enforce_admins = true

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

resource "github_issue_label" "emr-cluster-broker-client" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.emr-cluster-broker-client.name
}

