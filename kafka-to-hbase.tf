resource "github_repository" "kafka-to-hbase" {
  name        = "kafka-to-hbase"
  description = "Simple shovel utility to move messages from a Kafka topic to Hbase with versioning"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "kafka-to-hbase-dataworks" {
  repository = "${github_repository.kafka-to-hbase.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "kafka-to-hbase-master" {
  branch         = "${github_repository.kafka-to-hbase.default_branch}"
  repository     = "${github_repository.kafka-to-hbase.name}"
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
