resource "github_repository" "ucfs_claimant_kafka_consumer" {
  name        = "ucfs-claimant-kafka-consumer"
  description = "UCFS Claimant Kafka Consumer"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "ucfs_claimant_kafka_consumer_dataworks" {
  repository = github_repository.ucfs_claimant_kafka_consumer.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "ucfs_claimant_kafka_consumer_master" {
  branch         = github_repository.ucfs_claimant_kafka_consumer.default_branch
  repository     = github_repository.ucfs_claimant_kafka_consumer.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "ucfs_claimant_kafka_consumer" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.ucfs_claimant_kafka_consumer.name
}

resource "null_resource" "ucfs_claimant_kafka_consumer" {
  triggers = {
    repo = github_repository.ucfs_claimant_kafka_consumer.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.ucfs_claimant_kafka_consumer.name} '${github_repository.ucfs_claimant_kafka_consumer.description}' ${github_repository.ucfs_claimant_kafka_consumer.template.0.repository}"
  }
}

resource "github_actions_secret" "ucfs_claimant_kafka_consumer_dockerhub_password" {
  repository      = github_repository.ucfs_claimant_kafka_consumer.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "ucfs_claimant_kafka_consumer_dockerhub_username" {
  repository      = github_repository.ucfs_claimant_kafka_consumer.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "ucfs_claimant_kafka_consumer_snyk_token" {
  repository      = github_repository.ucfs_claimant_kafka_consumer.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
