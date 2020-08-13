resource "github_repository" "emr-cluster-broker" {
  name        = "emr-cluster-broker"
  description = "A lightweight API to passthrough requests to AWS SDK and create EMR clusters"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "emr-cluster-broker-dataworks" {
  repository = github_repository.emr-cluster-broker.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "emr-cluster-broker-master" {
  branch         = github_repository.emr-cluster-broker.default_branch
  repository     = github_repository.emr-cluster-broker.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "emr-cluster-broker-dockerhub-password" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = local.dockerhub_password
}

resource "github_actions_secret" "emr-cluster-broker-dockerhub-username" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = local.dockerhub_username
}

resource "github_actions_secret" "emr-cluster-broker-snyk-token" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = local.snyk_token
}

resource "github_actions_secret" "emr-cluster-broker-slack-webhook" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = local.slack_webhook_url
}

