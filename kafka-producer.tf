resource "github_repository" "kafka-producer" {
  name        = "kafka-producer"
  description = "Converts files in S3 to Kafka messages"

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "kafka-producer-dataworks" {
  repository = "${github_repository.kafka-producer.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "admin"
}

resource "github_branch_protection" "kafka-producer-master" {
  branch         = "${github_repository.kafka-producer.default_branch}"
  repository     = "${github_repository.kafka-producer.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}