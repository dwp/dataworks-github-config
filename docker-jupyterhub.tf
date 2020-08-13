resource "github_repository" "docker-jupyterhub" {
  name        = "docker-jupyterhub"
  description = "A JupyterHub container with required extensions and libraries"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = false

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_team_repository" "docker-jupyterhub-dataworks" {
  repository = github_repository.docker-jupyterhub.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker-jupyterhub-master" {
  branch         = github_repository.docker-jupyterhub.default_branch
  repository     = github_repository.docker-jupyterhub.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_actions_secret" "docker-jupyterhub_github_email" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "CI_GITHUB_EMAIL"
  plaintext_value = local.github_email
}

resource "github_actions_secret" "docker-jupyterhub_github_username" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "CI_GITHUB_USERNAME"
  plaintext_value = local.github_username
}

resource "github_actions_secret" "docker-jupyterhub_github_token" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "CI_GITHUB_TOKEN"
  plaintext_value = local.github_token
}

resource "github_actions_secret" "docker-jupyterhub-dockerhub-password" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = local.dockerhub_password
}

resource "github_actions_secret" "docker-jupyterhub-dockerhub-username" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = local.dockerhub_username
}

resource "github_actions_secret" "docker-jupyterhub-snyk-token" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = local.snyk_token
}

resource "github_actions_secret" "docker-jupyterhub-slack-webhook" {
  repository      = github_repository.docker-jupyterhub.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = local.slack_webhook_url
}

