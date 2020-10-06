resource "github_repository" "kafka-to-s3" {
  name        = "kafka-to-s3"
  description = "Read from Kafka topic and store in S3"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "kafka-to-s3-dataworks" {
  repository = github_repository.kafka-to-s3.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "kafka-to-s3-master" {
  branch         = github_repository.kafka-to-s3.default_branch
  repository     = github_repository.kafka-to-s3.name
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

resource "github_issue_label" "kafka-to-s3" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.kafka-to-s3.name
}

