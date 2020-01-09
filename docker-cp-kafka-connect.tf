resource "github_repository" "docker-cp-kafka-connect" {
  name        = "docker-cp-kafka-connect"
  description = "Confluent Kafka Connect Docker image with SSL certifciate signing "

  allow_merge_commit = false
  default_branch     = "master"
  has_issues         = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-cp-kafka-connect-dataworks" {
  repository = "${github_repository.docker-cp-kafka-connect.name}"
  team_id    = "${github_team.dataworks.id}"
  permission = "push"
}

resource "github_branch_protection" "docker-cp-kafka-connect-master" {
  branch         = "${github_repository.docker-cp-kafka-connect.default_branch}"
  repository     = "${github_repository.docker-cp-kafka-connect.name}"
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}
