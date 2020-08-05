resource "github_repository" "kafka_to_hbase_reconciliation" {
  name             = "kafka-to-hbase-reconciliation"
  description      = "Reconciliation to confirm that messages written from Kafka have been successfully written to HBase"
  auto_init        = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner = "${var.github_organization}"
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "kafka_to_hbase_reconciliation_dataworks" {
  repository = "${github_repository.kafka_to_hbase_reconciliation.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "kafka_to_hbase_reconciliation_master" {
  branch         = "${github_repository.kafka_to_hbase_reconciliation.default_branch}"
  repository     = "${github_repository.kafka_to_hbase_reconciliation.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "kafka_to_hbase_reconciliation" {
  triggers = {
    repo = "${github_repository.kafka_to_hbase_reconciliation.name}"
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.kafka_to_hbase_reconciliation.name} '${github_repository.kafka_to_hbase_reconciliation.description}' ${github_repository.kafka_to_hbase_reconciliation.template.0.repository}"
  }
}

resource "github_actions_secret" "kafka_to_hbase_reconciliation_dockerhub_password" {
  repository      = "${github_repository.kafka_to_hbase_reconciliation.name}"
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = "${var.dockerhub_password}"
}

resource "github_actions_secret" "kafka_to_hbase_reconciliation_dockerhub_username" {
  repository      = "${github_repository.kafka_to_hbase_reconciliation.name}"
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = "${var.dockerhub_username}"
}

resource "github_actions_secret" "kafka_to_hbase_reconciliation_snyk_token" {
  repository      = "${github_repository.kafka_to_hbase_reconciliation.name}"
  secret_name     = "SNYK_TOKEN"
  plaintext_value = "${var.snyk_token}"
}
