resource "github_repository" "kafka_queue_trawler" {
  name        = "kafka-queue-trawler"
  description = "Simple kafka queue trawler that lists records on the queue."
  auto_init   = true

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

resource "github_team_repository" "kafka_queue_trawler_dataworks" {
  repository = github_repository.kafka_queue_trawler.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "kafka_queue_trawler_master" {
  branch         = github_repository.kafka_queue_trawler.default_branch
  repository     = github_repository.kafka_queue_trawler.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "kafka_queue_trawler" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.kafka_queue_trawler.name
}

resource "null_resource" "kafka_queue_trawler" {
  triggers = {
    repo = github_repository.kafka_queue_trawler.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.kafka_queue_trawler.name} '${github_repository.kafka_queue_trawler.description}' ${github_repository.kafka_queue_trawler.template[0].repository}"
  }
}

resource "github_actions_secret" "kafka_queue_trawler_dockerhub_password" {
  repository      = github_repository.kafka_queue_trawler.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "kafka_queue_trawler_dockerhub_username" {
  repository      = github_repository.kafka_queue_trawler.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "kafka_queue_trawler_snyk_token" {
  repository      = github_repository.kafka_queue_trawler.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

