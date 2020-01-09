resource "github_repository" "kafka-to-s3" {
  name        = "kafka-to-s3"
  description = "Read from Kafka topic and store in S3"

  allow_merge_commit = false
  auto_init          = true
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "kafka-to-s3-dataworks" {
  repository = "${github_repository.kafka-to-s3.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "kafka-to-s3-master" {
  branch         = "${github_repository.kafka-to-s3.default_branch}"
  repository     = "${github_repository.kafka-to-s3.name}"
  enforce_admins = false

  required_status_checks {
    strict   = true
    contexts = ["ci/circleci: build-image"]
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
