resource "github_repository" "docker_create_metrics_data_batch" {
  name        = "docker-create-metrics-data-batch"
  description = "A container with required extensions and libraries for creating test data for Analytical Environment Performance Monitor"

  allow_merge_commit     = false
  delete_branch_on_merge = true
  auto_init              = true
  has_issues             = false

  lifecycle {
    prevent_destroy = true
  }

  template {
    owner      = var.github_organization
    repository = "dataworks-repo-template-docker"
  }
}

resource "github_team_repository" "docker_create_metrics_data_batch_dataworks" {
  repository = github_repository.docker_create_metrics_data_batch.name
  team_id    = github_team.dataworks.id
  permission = "push"
}

resource "github_branch_protection" "docker_create_metrics_data_batch_master" {
  branch         = github_repository.docker_create_metrics_data_batch.default_branch
  repository     = github_repository.docker_create_metrics_data_batch.name
  enforce_admins = false

  required_status_checks {
    strict = true
  }

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    require_code_owner_reviews = true
  }
}

resource "null_resource" "docker_create_metrics_data_batch" {
  triggers = {
    repo = github_repository.docker_create_metrics_data_batch.name
  }
  provisioner "local-exec" {
    command = "./initial-commit.sh ${github_repository.docker_create_metrics_data_batch.name} '${github_repository.docker_create_metrics_data_batch.description}' ${github_repository.docker_create_metrics_data_batch.template.0.repository}"
  }
}

resource "github_actions_secret" "docker_create_metrics_data_batch_dockerhub_password" {
  repository      = github_repository.docker_create_metrics_data_batch.name
  secret_name     = "DOCKERHUB_PASSWORD"
  plaintext_value = var.dockerhub_password
}

resource "github_actions_secret" "docker_create_metrics_data_batch_username" {
  repository      = github_repository.docker_create_metrics_data_batch.name
  secret_name     = "DOCKERHUB_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "docker_create_metrics_data_batch_snyk_token" {
  repository      = github_repository.docker_create_metrics_data_batch.name
  secret_name     = "SNYK_TOKEN"
  plaintext_value = var.snyk_token
}
