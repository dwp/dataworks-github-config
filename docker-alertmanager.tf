resource "github_repository" "docker_alertmanager" {
  name        = "docker-alertmanager"
  description = "Rebuild of Alertmanager Docker image for DataWorks"
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

resource "github_team_repository" "docker_alertmanager_dataworks" {
  repository = github_repository.docker_alertmanager.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_alertmanager_master" {
  branch         = github_repository.docker_alertmanager.default_branch
  repository     = github_repository.docker_alertmanager.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "docker_alertmanager" {
  triggers = {
    repo = github_repository.docker_alertmanager.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.docker_alertmanager.name} '${github_repository.docker_alertmanager.description}' ${github_repository.docker_alertmanager.template[0].repository}"
  }
}

resource "github_actions_secret" "docker_alertmanager_dockerhub_password" {
  repository      = github_repository.docker_alertmanager.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = local.dockerhub_password
}

resource "github_actions_secret" "docker_alertmanager_dockerhub_username" {
  repository      = github_repository.docker_alertmanager.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = local.dockerhub_username
}

resource "github_actions_secret" "docker_alertmanager_snyk_token" {
  repository      = github_repository.docker_alertmanager.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = local.snyk_token
}

