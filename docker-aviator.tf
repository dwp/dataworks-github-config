resource "github_repository" "docker_aviator" {
  name        = "docker-aviator"
  description = "Docker image that will run Aviator"
  auto_init   = false

  allow_merge_commit     = false
  delete_branch_on_merge = true
  has_issues             = true
  topics                 = local.common_topics

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "docker_aviator_dataworks" {
  repository = github_repository.docker_aviator.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_aviator_master" {
  branch         = github_repository.docker_aviator.default_branch
  repository     = github_repository.docker_aviator.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker_aviator" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker_aviator.name
}

resource "null_resource" "docker_aviator" {
  triggers = {
    repo = github_repository.docker_aviator.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.docker_aviator.name} '${github_repository.docker_aviator.description}' ${github_repository.docker_aviator.template.0.repository}"
  }
}

resource "github_actions_secret" "docker_aviator_dockerhub_password" {
  repository      = github_repository.docker_aviator.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker_aviator_dockerhub_username" {
  repository      = github_repository.docker_aviator.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker_aviator_snyk_token" {
  repository      = github_repository.docker_aviator.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
