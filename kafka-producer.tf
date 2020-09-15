resource "github_repository" "kafka-producer" {
  name        = "kafka-producer"
  description = "Converts files in S3 to Kafka messages"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "kafka-producer-dataworks" {
  repository = github_repository.kafka-producer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "kafka-producer-master" {
  branch         = github_repository.kafka-producer.default_branch
  repository     = github_repository.kafka-producer.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "kafka-producer_github_email" {
  repository      = github_repository.kafka-producer.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = var.github_email
}

resource "github_actions_secret" "kafka-producer_github_username" {
  repository      = github_repository.kafka-producer.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = var.github_username
}

resource "github_actions_secret" "kafka-producer_github_token" {
  repository      = github_repository.kafka-producer.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = var.github_token
}

