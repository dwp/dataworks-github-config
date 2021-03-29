resource "github_repository" "docker-jq-curl" {
  name        = "docker-jq-curl"
  description = "Docker container with JQ and Curl"
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  default_branch         = "master"
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-jq-curl-dataworks" {
  repository = github_repository.docker-jq-curl.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-jq-curl-master" {
  branch         = github_repository.docker-jq-curl.default_branch
  repository     = github_repository.docker-jq-curl.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker-jq-curl" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker-jq-curl.name
}

resource "github_actions_secret" "docker-jq-curl_dockerhub_password" {
  repository      = github_repository.docker-jq-curl.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker-jq-curl_dockerhub_username" {
  repository      = github_repository.docker-jq-curl.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker-jq-curl_snyk_token" {
  repository      = github_repository.docker-jq-curl.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
