resource "github_repository" "docker-nifi-s3" {
  name        = "docker-nifi-s3"
  description = "Docker container for Apache NiFi that retrieves config from S3 location on launch. Container images published to https://hub.docker.com/r/dwpdigital/nifi-s3."
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-nifi-s3-dataworks" {
  repository = github_repository.docker-nifi-s3.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-nifi-s3-master" {
  branch         = github_repository.docker-nifi-s3.default_branch
  repository     = github_repository.docker-nifi-s3.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker-nifi-s3_dockerhub_password" {
  repository      = github_repository.docker-nifi-s3.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker-nifi-s3_dockerhub_username" {
  repository      = github_repository.docker-nifi-s3.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker-nifi-s3_snyk_token" {
  repository      = github_repository.docker-nifi-s3.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

