resource "github_repository" "emr-cluster-broker" {
  name        = "emr-cluster-broker"
  description = "A lightweight API to passthrough requests to AWS SDK and create EMR clusters"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

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
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "emr-cluster-broker" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.emr-cluster-broker.name
}

resource "github_actions_secret" "emr-cluster-broker-dockerhub-password" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "emr-cluster-broker-dockerhub-username" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "emr-cluster-broker-snyk-token" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "emr-cluster-broker-slack-webhook" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook_url
}

resource "github_actions_secret" "terraform_version" {
  repository      = github_repository.emr-cluster-broker.name
  secret_name     = "TERRAFORM_VERSION"
  plaintext_value = var.terraform_12_version
}
