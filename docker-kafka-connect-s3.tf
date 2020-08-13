resource "github_repository" "docker-kafka-connect-s3" {
  name        = "docker-kafka-connect-s3"
  description = "Docker Container for Confluent Connect with S3 Plugin"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-kafka-connect-s3-dataworks" {
  repository = github_repository.docker-kafka-connect-s3.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-kafka-connect-s3-master" {
  branch         = github_repository.docker-kafka-connect-s3.default_branch
  repository     = github_repository.docker-kafka-connect-s3.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

