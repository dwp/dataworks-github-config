resource "github_repository" "rstudiooss" {
  name        = "docker-rstudio-oss"
  description = "Docker image for RStudio OSS and assocaited dependancies."
  auto_init   = true

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "rstudiooss_dataworks" {
  repository = github_repository.rstudiooss.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "rstudiooss_master" {
  branch         = github_repository.rstudiooss.default_branch
  repository     = github_repository.rstudiooss.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "rstudiooss" {
  triggers = {
    repo = github_repository.rstudiooss.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.rstudiooss.name} '${github_repository.rstudiooss.description}' ${github_repository.rstudiooss.template[0].repository}"
  }
}

resource "github_actions_secret" "rstudiooss_dockerhub_password" {
  repository      = github_repository.rstudiooss.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "rstudiooss_dockerhub_username" {
  repository      = github_repository.rstudiooss.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "rstudiooss_snyk_token" {
  repository      = github_repository.rstudiooss.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

resource "github_actions_secret" "rstudiooss_slack_webhook" {
  repository      = github_repository.rstudiooss.name
  secret_name     = "SLACK_WEBHOOK"
  plaintext_value = var.slack_webhook_url
}

