resource "github_repository" "docker-headless-chrome" {
  name        = "docker-headless-chrome"
  description = "Dataworks hardened headless Chrome container"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  auto_init              = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-headless-chrome-dataworks" {
  repository = github_repository.docker-headless-chrome.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-headless-chrome-master" {
  branch         = github_repository.docker-headless-chrome.default_branch
  repository     = github_repository.docker-headless-chrome.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker-headless-chrome-dockerhub-password" {
  repository      = github_repository.docker-headless-chrome.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = local.dockerhub_password
}

resource "github_actions_secret" "docker-headless-chrome-dockerhub-username" {
  repository      = github_repository.docker-headless-chrome.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = local.dockerhub_username
}

resource "github_actions_secret" "docker-headless-chrome-snyk-token" {
  repository      = github_repository.docker-headless-chrome.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = local.snyk_token
}

