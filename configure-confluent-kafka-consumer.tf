resource "github_repository" "configure-confluent-kafka-consumer" {
  name        = "configure-confluent-kafka-consumer"
  description = "Configure Confluent Kafka Consumers using RESTful API"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "configure-confluent-kafka-consumer-dataworks" {
  repository = "${github_repository.configure-confluent-kafka-consumer.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "configure-confluent-kafka-consumer-master" {
  branch         = "${github_repository.configure-confluent-kafka-consumer.default_branch}"
  repository     = "${github_repository.configure-confluent-kafka-consumer.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "configure-confluent-kafka-consumer_github_email" {
  repository      = "${github_repository.configure-confluent-kafka-consumer.name}"
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = "${var.github_email}"
}

resource "github_actions_secret" "configure-confluent-kafka-consumer_github_username" {
  repository      = "${github_repository.configure-confluent-kafka-consumer.name}"
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = "${var.github_username}"
}

resource "github_actions_secret" "configure-confluent-kafka-consumer_github_token" {
  repository      = "${github_repository.configure-confluent-kafka-consumer.name}"
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = "${var.github_token}"
}
