resource "github_repository" "docker_ecs_service_discovery" {
  name        = "docker-ecs-service-discovery"
  description = "Repo for the Docker ECS service discovery service for use with Prometheus"
  auto_init   = true

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

resource "github_team_repository" "docker_ecs_service_discovery_dataworks" {
  repository = github_repository.docker_ecs_service_discovery.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_ecs_service_discovery_master" {
  branch         = github_repository.docker_ecs_service_discovery.default_branch
  repository     = github_repository.docker_ecs_service_discovery.name
  enforce_admins = true

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "github_issue_label" "docker_ecs_service_discovery" {
  for_each   = { for common_label in local.common_labels : common_label.name => common_label }
  color      = each.value.colour
  name       = each.value.name
  repository = github_repository.docker_ecs_service_discovery.name
}

resource "null_resource" "docker_ecs_service_discovery" {
  triggers = {
    repo = github_repository.docker_ecs_service_discovery.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.docker_ecs_service_discovery.name} '${github_repository.docker_ecs_service_discovery.description}' ${github_repository.docker_ecs_service_discovery.template[0].repository}"
  }
}

resource "github_actions_secret" "docker_ecs_service_discovery_dockerhub_password" {
  repository      = github_repository.docker_ecs_service_discovery.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker_ecs_service_discovery_dockerhub_username" {
  repository      = github_repository.docker_ecs_service_discovery.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker_ecs_service_discovery_snyk_token" {
  repository      = github_repository.docker_ecs_service_discovery.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}

